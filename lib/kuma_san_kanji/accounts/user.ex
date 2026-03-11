defmodule KumaSanKanji.Accounts.User do
  use Ash.Resource,
    otp_app: :kuma_san_kanji,
    domain: KumaSanKanji.Accounts,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication],
    data_layer: AshPostgres.DataLayer

  postgres do
    table("users")
    repo(KumaSanKanji.Repo)
  end

  authentication do
    strategies do
      password :password do
        identity_field(:email)
        hashed_password_field(:hashed_password)
        confirmation_required?(false)
      end
    end

    add_ons do
      log_out_everywhere do
        apply_on_password_change?(true)
      end
    end

    tokens do
      enabled?(true)
      token_resource(KumaSanKanji.Accounts.Token)
      signing_secret(KumaSanKanji.Secrets)
      store_all_tokens?(true)
      require_token_presence_for_authentication?(true)
    end
  end

  actions do
    create :register_with_password do
      argument(:password, :string, allow_nil?: false, sensitive?: true)
      argument(:password_confirmation, :string, sensitive?: true)

      accept([:email])

      change(AshAuthentication.GenerateTokenChange)
      change(AshAuthentication.Strategy.Password.HashPasswordChange)

      # Derive username from email
      change(fn changeset, _ ->
        email = Ash.Changeset.get_attribute(changeset, :email)

        if email do
          username =
            email |> to_string() |> String.split("@") |> List.first() |> String.downcase()

          Ash.Changeset.change_attribute(changeset, :username, username)
        else
          changeset
        end
      end)
    end

    # Simple create action for testing and seeding
    create :create_for_test do
      accept([:email, :username, :admin, :dev_mode_enabled])
      # Timestamps will be automatically set by Ash
    end

    update :toggle_dev_mode do
      argument :enabled, :boolean do
        allow_nil?(false)
      end

      change(set_attribute(:dev_mode_enabled, arg(:enabled)))
    end

    # Generic update action for admin operations
    update :update do
      accept([:admin, :dev_mode_enabled])
    end

    # Destroy action for cleanup
    destroy(:destroy)

    defaults([:read])

    read :get_by_subject do
      description("Get a user by the subject claim in a JWT")
      argument(:subject, :string, allow_nil?: false)
      get?(true)
      prepare(AshAuthentication.Preparations.FilterBySubject)
    end

    # Return a single user with loaded SRS progress aggregates/calculation
    read :progress_summary do
      get?(true)

      prepare(fn query, _ctx ->
        query
        |> Ash.Query.load([
          :kanji_progress_count,
          :total_reviews_sum,
          :correct_reviews_sum,
          :accuracy
        ])
      end)
    end
  end

  relationships do
    # Link to spaced repetition progress records
    has_many(:kanji_progress, KumaSanKanji.SRS.UserKanjiProgress)
  end

  aggregates do
    # Total number of tracked kanji for this user
    count(:kanji_progress_count, :kanji_progress)
    # Sum review counters
    sum(:total_reviews_sum, :kanji_progress, :total_reviews)
    sum(:correct_reviews_sum, :kanji_progress, :correct_reviews)
  end

  calculations do
    # Accuracy % derived from aggregates; 0 if none
    calculate(
      :accuracy,
      :decimal,
      expr(
        cond do
          total_reviews_sum == 0 -> 0
          true -> correct_reviews_sum * 100 / total_reviews_sum
        end
      )
    )
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if(always())
    end

    # Temporarily allow all read operations for debugging
    policy action_type(:read) do
      authorize_if(always())
    end

    # Only admins can toggle dev mode for users
    policy action(:toggle_dev_mode) do
      authorize_if(actor_attribute_equals(:admin, true))
    end

    # Allow create_for_test for testing purposes
    policy action(:create_for_test) do
      authorize_if(always())
    end

    # Allow generic update for admin operations
    policy action(:update) do
      authorize_if(actor_attribute_equals(:admin, true))
    end

    # Allow destroy for cleanup (admin only)
    policy action(:destroy) do
      authorize_if(actor_attribute_equals(:admin, true))
    end
  end

  attributes do
    uuid_primary_key(:id, writable?: true, public?: true)

    attribute(:username, :ci_string, allow_nil?: false, public?: true)
    attribute(:email, :ci_string, allow_nil?: false, public?: true)
    attribute(:hashed_password, :string, allow_nil?: true, sensitive?: true)

    attribute :dev_mode_enabled, :boolean do
      default(false)
      description("Allows user to see development features in production")
    end

    attribute :admin, :boolean do
      default(false)
      description("Grants administrative privileges")
    end

    create_timestamp(:created_at)
    update_timestamp(:updated_at)
  end

  identities do
    identity(:unique_email, [:email])
  end

  # Code interface for convenient access
  code_interface do
    define(:get_by_id, action: :read, get_by: [:id])
    define(:get_by_subject, action: :get_by_subject, get_by: [:subject])
    define(:progress_summary, action: :progress_summary, get_by: [:id])
  end
end
