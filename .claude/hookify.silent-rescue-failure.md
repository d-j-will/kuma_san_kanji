---
name: warn-silent-rescue-failure
enabled: true
event: file
conditions:
  - field: new_text
    operator: regex_match
    pattern: rescue[\s\S]*?->\s*(:ok|nil|:error)\s*$
---

**Silent failure pattern detected — `rescue _ -> :ok`**

You are writing a rescue clause that silently discards errors. This hides broken functionality — the only symptom is missing data that nobody notices until they need it.

**What to do instead:**
```elixir
# BAD — hides failures
rescue
  _ -> :ok

# GOOD — makes failures visible
rescue
  error ->
    Logger.warning("function_name failed: #{inspect(error)}")
    :ok
```

Every failure must be visible in logs. See CLAUDE.md "Production Resilience" section.
