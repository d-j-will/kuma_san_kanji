---
name: warn-docker-latest-tag
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: docker-compose.*\.yml$
  - field: new_text
    operator: regex_match
    pattern: "image:.*:latest"
---

**`:latest` tag detected in Docker Compose file**

You are using an unpinned `:latest` tag for a Docker image. Major version changes break configs silently.

**What to do:**
1. Check the current stable version on Docker Hub or the image registry
2. Pin to a specific version tag (e.g., `postgres:16` not `postgres:latest`)

**Exception:** The app image (`ghcr.io/davewil/kuma-san-kanji:latest`) is acceptable because it is always built and tagged by CI — `:latest` always refers to the most recent successful build.
