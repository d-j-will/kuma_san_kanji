defmodule KumaSanKanji.Accounts.User do
  use Ash.Resource,
    otp_app: :kuma_san_kanji,
    domain: KumaSanKanji.Accounts,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "users"
    repo KumaSanKanji.Repo
  end

  authentication do
    strategies do
      auth0 do
        client_id KumaSanKanji.Secrets
        redirect_uri KumaSanKanji.Secrets
        client_secret KumaSanKanji.Secrets
        base_url KumaSanKanji.Secrets
      end
    end

    add_ons do
      log_out_everywhere do
        apply_on_password_change? true
      end
    end

    tokens do
      enabled? true
      token_resource KumaSanKanji.Accounts.Token
      signing_secret KumaSanKanji.Secrets
      store_all_tokens? true
      require_token_presence_for_authentication? true
    end
  end

  actions do
    create :register_with_auth0 do
      argument :user_info, :map, allow_nil?: false
      argument :oauth_tokens, :map, allow_nil?: false
      upsert? true
      upsert_identity :unique_email

      change AshAuthentication.GenerateTokenChange

      change fn changeset, _ ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)
        email = Map.get(user_info, "email")

        username =
          email
          |> String.split("@")
          |> List.first()
          |> String.downcase()

        changeset
        |> Ash.Changeset.change_attributes(%{email: email, username: username})
      end
    end

    # Simple create action for testing and seeding
    create :create_for_test do
      accept [:email, :username, :admin, :dev_mode_enabled]
      # Timestamps will be automatically set by Ash
    end

    update :toggle_dev_mode do
      argument :enabled, :boolean do
        allow_nil? false
      end
      
      change set_attribute(:dev_mode_enabled, arg(:enabled))
    end

    # Generic update action for admin operations
    update :update do
      accept [:admin, :dev_mode_enabled]
    end

    # Destroy action for cleanup
    destroy :destroy

    defaults [:read]

    read :get_by_subject do
      description "Get a user by the subject claim in a JWT"
      argument :subject, :string, allow_nil?: false
      get? true
      prepare AshAuthentication.Preparations.FilterBySubject
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    # Only admins can toggle dev mode for users
    policy action(:toggle_dev_mode) do
      authorize_if actor_attribute_equals(:admin, true)
    end

    # Allow basic read operations
    policy action_type(:read) do
      authorize_if always()
    end

    # Allow create_for_test for testing purposes
    policy action(:create_for_test) do
      authorize_if always()
    end

    # Allow generic update for admin operations
    policy action(:update) do
      authorize_if always()  # We'll control this at the application level
    end

    # Allow destroy for cleanup
    policy action(:destroy) do
      authorize_if always()
    end

    # Default to forbidding other actions
    policy always() do
      forbid_if always()
    end
  end

  attributes do
    uuid_primary_key :id, writable?: true

    attribute :username, :ci_string, allow_nil?: false, public?: true
    attribute :email, :ci_string, allow_nil?: false

    attribute :dev_mode_enabled, :boolean do
      default false
      description "Allows user to see development features in production"
    end

    attribute :admin, :boolean do
      default false
      description "Grants administrative privileges"
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  identities do
    identity :unique_email, [:email]
  end
end
