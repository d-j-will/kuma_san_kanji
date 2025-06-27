# Create development user for testing
# 
# ⚠️  OBSOLETE: This script is no longer needed after Auth0 migration.
# Authentication is now handled via Auth0, so dev users should be created
# through the Auth0 dashboard or sign-up flow at /sign-in
#
# This script is kept for reference only.

alias KumaSanKanji.Accounts.User
require Ash.Query

IO.puts("⚠️  This script is OBSOLETE after Auth0 migration!")
IO.puts("")
IO.puts("With Auth0 authentication, users are now created through:")
IO.puts("1. Auth0 Dashboard (for admin-created users)")
IO.puts("2. Sign-up flow at /sign-in (for self-service registration)")
IO.puts("")
IO.puts("To create a dev user:")
IO.puts("1. Start the application: mix phx.server")
IO.puts("2. Navigate to http://localhost:4000/sign-in")
IO.puts("3. Click 'Sign up' and create an account")
IO.puts("")
IO.puts("This script is maintained for reference purposes only.")

# Legacy code (no longer functional with Auth0):
# User.sign_up/3 action no longer exists - users are created via Auth0
