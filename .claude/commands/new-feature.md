Scaffold a new feature behind a FunWithFlags feature flag.

## Steps

1. **Ask for the feature name** if not already provided. Clarify:
   - A short snake_case identifier (e.g., `srs_intervals`, `stroke_order_quiz`)
   - A one-sentence description of what the feature does

2. **Create or verify the feature flag exists**:
   ```elixir
   # In iex or a migration/seed:
   FunWithFlags.enable(:feature_name)
   ```

3. **Add the flag check** wherever the feature is surfaced:
   ```elixir
   # In LiveView or controller:
   if FunWithFlags.enabled?(:feature_name) do
     # new feature code
   else
     # existing behavior or hidden
   end
   ```

   For LiveView, prefer checking in `mount/3` or `handle_params/3` and assigning to the socket:
   ```elixir
   def mount(_params, _session, socket) do
     {:ok, assign(socket, feature_name_enabled: FunWithFlags.enabled?(:feature_name))}
   end
   ```

4. **Gate routes if needed** — for entirely new pages behind a flag, add a plug or check in the LiveView's `mount`:
   ```elixir
   if not FunWithFlags.enabled?(:feature_name) do
     {:ok, socket |> put_flash(:error, "Feature not available") |> redirect(to: ~p"/")}
   end
   ```

5. **Add tests with the flag in both states**:
   ```elixir
   describe "with :feature_name enabled" do
     setup do
       FunWithFlags.enable(:feature_name)
       on_exit(fn -> FunWithFlags.disable(:feature_name) end)
       :ok
     end

     test "shows the new feature" do
       # ...
     end
   end

   describe "with :feature_name disabled" do
     setup do
       FunWithFlags.disable(:feature_name)
       :ok
     end

     test "hides the new feature" do
       # ...
     end
   end
   ```

6. **Document the flag** — add an entry to the feature flags table below.

## Active Feature Flags

| Flag | Description | Added | Status |
|------|-------------|-------|--------|
| _(none yet)_ | | | |

## Important

- Every new user-facing feature **must** be behind a flag.
- Flags default to **disabled** in production. Enable via the admin UI at `/admin/feature-flags` or `FunWithFlags.enable/1` in a remote console.
- When a feature is fully rolled out and stable, remove the flag checks (contract phase) — don't leave stale flags.
- Test both flag states. A feature that crashes when its flag is off is not properly gated.
