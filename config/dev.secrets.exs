# Auth0 Development Secrets (Local Overrides)
import Config

# This file is intended for local development secrets and should NOT be committed to Git.
# It is specifically excluded by .gitignore.
#
# Configure these values via environment variables instead of hardcoding secrets.
# Example:
#   export AUTH0_CLIENT_ID="..."
#   export AUTH0_CLIENT_SECRET="..."
#   export AUTH0_DOMAIN="https://your-tenant.auth0.com"
#   export AUTH0_REDIRECT_URI="http://localhost:4000/auth/user/auth0/callback"
#
# Values defined here will OVERRIDE any defaults set in config/dev.exs

config :kuma_san_kanji,
  auth0: [
    client_id: System.fetch_env!("AUTH0_CLIENT_ID"),
    client_secret: System.fetch_env!("AUTH0_CLIENT_SECRET"),
    # This is your Auth0 Tenant Domain (e.g., https://dev-xxxx.us.auth0.com)
    base_url: System.get_env("AUTH0_DOMAIN", "https://your-domain.auth0.com"),
    # This should match your Auth0 Application's Allowed Callback URLs
    redirect_uri:
      System.get_env("AUTH0_REDIRECT_URI", "http://localhost:4000/auth/user/auth0/callback")
  ]
