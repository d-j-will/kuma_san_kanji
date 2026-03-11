# Auth0 Development Secrets (Local Overrides)
import Config

# This file is intended for local development secrets and should NOT be committed to Git.
# It is specifically excluded by .gitignore.

# Values defined here will OVERRIDE any defaults set in config/dev.exs

# To get these values from Auth0:
# 1. Log in to your Auth0 dashboard.
# 2. Navigate to your Application settings.
# 3. Copy the Client ID, Client Secret, and Domain.

config :kuma_san_kanji,
  auth0: [
    client_id: "2mVNdcqRVcsz0rN6Zqs9u1NDIMYnaaDg",
    client_secret: "zvaHz38W8nQbH4cQPDKZkqnNidCKPYORfWkLKCeAjvURhD8lLON-s31lEx7bJp5V",
    # This is your Auth0 Tenant Domain (e.g., https://dev-xxxx.us.auth0.com)
    base_url: "https://dev-d5s0b3ztq5peoe3y.uk.auth0.com",
    # This should match your Auth0 Application's Allowed Callback URLs
    redirect_uri: "http://localhost:4000/auth/user/auth0/callback"
  ]
