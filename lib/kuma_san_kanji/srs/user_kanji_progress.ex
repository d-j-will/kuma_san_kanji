defmodule KumaSanKanji.SRS.UserKanjiProgress do
  @moduledoc """
  Tracks each user's kanji review progress for the Spaced Repetition System (SRS).

  Implements the SM-2 algorithm for calculating review intervals based on user performance.
  Ensures secure access control - users can only access/modify their own progress.
  """

  use Ash.Resource,
    domain: KumaSanKanji.Domain,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  attributes do
    uuid_primary_key(:id)

    # SRS state tracking
    attribute(:next_review_date, :utc_datetime, allow_nil?: false)
    # Days between reviews
    attribute(:interval, :integer, default: 1, allow_nil?: false)
    # SM-2 ease factor
    attribute(:ease_factor, :decimal, default: Decimal.new("2.5"), allow_nil?: false)
    # Successful repetitions count
    attribute(:repetitions, :integer, default: 0, allow_nil?: false)
    # :correct, :incorrect, :skip
    attribute(:last_result, :atom, allow_nil?: true)

    # Tracking metadata
    attribute(:first_reviewed_at, :utc_datetime, allow_nil?: true)
    attribute(:last_reviewed_at, :utc_datetime, allow_nil?: true)
    attribute(:total_reviews, :integer, default: 0, allow_nil?: false)
    attribute(:correct_reviews, :integer, default: 0, allow_nil?: false)

    timestamps()
  end

  relationships do
    belongs_to(:user, KumaSanKanji.Accounts.User,
      allow_nil?: false,
      define_attribute?: true
    )

    belongs_to(:kanji, KumaSanKanji.Kanji.Kanji,
      allow_nil?: false,
      define_attribute?: true
    )
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:user_id, :kanji_id, :next_review_date, :interval, :ease_factor, :repetitions])

      change(fn changeset, _context ->
        # Set initial review date to now if not provided
        case Ash.Changeset.get_attribute(changeset, :next_review_date) do
          nil -> Ash.Changeset.change_attribute(changeset, :next_review_date, DateTime.utc_now())
          _ -> changeset
        end
      end)
    end

    # Default update action with essential fields
    update :update do
      accept([
        :next_review_date,
        :interval,
        :ease_factor,
        :repetitions,
        :last_result,
        :first_reviewed_at,
        :last_reviewed_at,
        :total_reviews,
        :correct_reviews
      ])
    end

    # Custom action to initialize progress for a user-kanji pair
    create :initialize do
      upsert? true
      upsert_identity :unique_user_kanji
      argument(:user_id, :uuid, allow_nil?: false)
      argument(:kanji_id, :uuid, allow_nil?: false)

      change(fn changeset, _context ->
        user_id = Ash.Changeset.get_argument(changeset, :user_id)
        kanji_id = Ash.Changeset.get_argument(changeset, :kanji_id)

        changeset
        |> Ash.Changeset.change_attribute(:user_id, user_id)
        |> Ash.Changeset.change_attribute(:kanji_id, kanji_id)
        |> Ash.Changeset.change_attribute(:next_review_date, DateTime.utc_now())
        |> Ash.Changeset.change_attribute(:interval, 1)
        |> Ash.Changeset.change_attribute(:ease_factor, Decimal.new("2.5"))
        |> Ash.Changeset.change_attribute(:repetitions, 0)
      end)
    end

    # Action to record a review result and update SRS state
    update :record_review do
      accept([:last_result])
      require_atomic? false

      # Use extracted change module for SM-2 logic
      change KumaSanKanji.SRS.Changes.ApplySm2
    end

    # Read action to get progress for a specific user-kanji pair
    read :get_user_kanji_progress do
      argument(:user_id, :uuid, allow_nil?: false)
      argument(:kanji_id, :uuid, allow_nil?: false)

      prepare(fn query, _context ->
        user_id = Ash.Query.get_argument(query, :user_id)
        kanji_id = Ash.Query.get_argument(query, :kanji_id)

        Ash.Query.do_filter(query,
          user_id: user_id,
          kanji_id: kanji_id
        )
      end)
    end

    # Read action to get kanji due for review for a user
    read :due_for_review do
      argument(:user_id, :uuid, allow_nil?: false)
      argument(:limit, :integer, default: 10)
  # Horizon (in seconds) to look ahead; 0 means only items currently due
  # Look-ahead horizon in seconds (default 1 hour) to prefetch near-due items
  argument(:horizon_seconds, :integer, default: 3600)

      prepare(fn query, _context ->
        user_id = Ash.Query.get_argument(query, :user_id)
        horizon_seconds =
          case Ash.Query.get_argument(query, :horizon_seconds) do
            nil -> 0
            v when is_integer(v) and v > 0 -> v
            _ -> 0
          end
        now = DateTime.utc_now()
        horizon_time = DateTime.add(now, horizon_seconds, :second)

        query
        |> Ash.Query.do_filter(
          user_id: user_id,
          next_review_date: [lte: horizon_time]
        )
      end)

      prepare(fn query, _context ->
        query
        |> Ash.Query.sort(:next_review_date)
        |> Ash.Query.limit(Map.get(query.arguments, :limit, 10))
      end)
    end

    # Read action to get user's progress stats
    read :user_stats do
      argument(:user_id, :uuid, allow_nil?: false)

      prepare(fn query, _context ->
        user_id = Ash.Query.get_argument(query, :user_id)
        Ash.Query.do_filter(query, user_id: user_id)
      end)
    end
  end

  policies do
    # Allow admin bypass for all actions
    bypass action_type([:read, :create, :update, :destroy]) do
      authorize_if actor_attribute_equals(:admin, true)
    end

    # For authenticated users, they can only access their own progress records
    policy action_type([:read, :update, :destroy]) do
      authorize_if relates_to_actor_via(:user)
    end

    # For create actions, check that the user_id argument matches the actor
    policy action_type(:create) do
      authorize_if expr(^actor(:id) == ^arg(:user_id))
    end
  end

  code_interface do
    define(:create, action: :create)
    define(:initialize, action: :initialize)
    define(:record_review, action: :record_review)
    define(:get_user_kanji_progress, action: :get_user_kanji_progress)
    define(:due_for_review, action: :due_for_review)
    define(:user_stats, action: :user_stats)
  end

  identities do
    # Prevent duplicate progress entries for the same user/kanji
    identity(:unique_user_kanji, [:user_id, :kanji_id])
  end

  postgres do
    table("user_kanji_progress")
    repo(KumaSanKanji.Repo)
  end

  # (legacy update_srs_state/1 removed; SM-2 logic resides in KumaSanKanji.SRS.Changes.ApplySm2)

  @doc """
  Implements the SM-2 algorithm for calculating review intervals.

  ## Parameters
  - interval: Current interval in days
  - ease_factor: Current ease factor (should be >= 1.3)
  - repetitions: Number of successful repetitions
  - quality: Quality of response (0-5, where 5 is perfect)

  ## Returns
  {new_interval, new_ease_factor}
  """
  def calculate_sm2_interval(interval, ease_factor, repetitions, quality) do
    # Convert ease_factor to float for calculation
    ef = Decimal.to_float(ease_factor)

    # Calculate new ease factor
    new_ef = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
    # Minimum ease factor is 1.3
    new_ef = max(new_ef, 1.3)

    # Calculate new interval
    new_interval =
      case repetitions do
        1 -> 1
        2 -> 6
        n when n > 2 -> round(interval * new_ef)
        _ -> 1
      end

    {new_interval, Decimal.from_float(new_ef)}
  end
end
