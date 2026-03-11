---
name: warn-library-doc-verification
enabled: true
event: file
conditions:
  - field: new_text
    operator: regex_match
    pattern: (AshAuthentication\.|AshPostgres\.|Ash\.Resource|Ash\.Query|Ash\.Changeset|Phoenix\.LiveView\.JS\.|Plug\.|Ecto\.Adapters|FunWithFlags\.)
---

**Library API usage detected — doc verification required**

You are writing code that depends on a library's API. Before proceeding, you **must** verify the API against current documentation.

**Required steps:**
1. Use `context7` MCP tool to resolve the library ID and query its docs, OR
2. Use `WebFetch` to fetch the hex.pm docs or GitHub README directly, OR
3. Run `mix hex.info <package>` to verify version compatibility

**What must be verified:**
- Function signatures and required options
- Return value shapes (don't assume — verify)
- Configuration options and defaults

See CLAUDE.md for details.
