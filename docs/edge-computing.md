# Edge Computing for KumaSanKanji

This document outlines practical ways to use edge computing to improve performance, reliability, and user experience for KumaSanKanji. It’s tailored to Ash patterns: keep business logic inside resource actions, expose via domain code interfaces, and keep LiveViews/controllers thin.

## Goals

- Instant, resilient study sessions (offline-first UX)
- Lower latency worldwide with safe write routing
- Protect the origin via edge throttling and caching
- Keep a single source of truth in Ash resources

## High-level architecture

- Client edge (browser): Service Worker caches core UI and queues review events offline using IndexedDB + Background Sync.
- Edge worker (CDN/runtime near the user): Accepts small POST events, adds idempotency and retries, forwards to origin with signed requests; optionally 202 + buffer.
- Origin (Phoenix/Ash): Ingests events into an append-only ReviewEvent resource; an Oban worker calls the authoritative record_review action on UserKanjiProgress.
- Reads: CDN caches explore pages and precomputed JSON bundles; multi-region read replicas are optional; writes always go to the primary.

## 1) Offline-first reviews with background sync (client edge)

- Why: Zero-latency interactions on flaky networks.
- How: Service Worker caches shell and assets; submissions enqueue while offline; sync when online.

```javascript
// public/sw.js (example, register it from assets/js/app.js)
self.addEventListener('install', e => {
  e.waitUntil(caches.open('kuma-v1').then(c => c.addAll([
    '/', '/quiz', '/assets/app.css', '/assets/app.js'
  ])));
  self.skipWaiting();
});

self.addEventListener('fetch', e => {
  e.respondWith(caches.match(e.request).then(res => res || fetch(e.request)));
});

self.addEventListener('sync', e => {
  if (e.tag === 'review-sync') e.waitUntil(flushQueuedReviews());
});

async function flushQueuedReviews() {
  const items = await loadQueued(); // implement IndexedDB queue
  for (const evt of items) {
    try {
      await fetch('/api/edge/reviews', {
        method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(evt)
      });
      await markFlushed(evt.id);
    } catch (_) { /* keep queued */ }
  }
}
```

Notes

- Keep SM-2 feedback in the UI for UX; server remains the authority.
- Use a simple IndexedDB store keyed by event id.

## 2) Idempotent review ingest at the origin (Ash)

Create an append-only resource to accept edge events safely; dedupe via an idempotency key; process asynchronously.

```elixir
# lib/kuma_san_kanji/srs/review_event.ex

defmodule KumaSanKanji.SRS.ReviewEvent do
  use Ash.Resource,
    domain: KumaSanKanji.Domain,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "review_events"
    repo KumaSanKanji.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :user_id, :uuid, allow_nil?: false
    attribute :progress_id, :uuid, allow_nil?: false
    attribute :result, :atom do
      constraints one_of: [:correct, :incorrect, :skip]
      allow_nil? false
    end
    attribute :idempotency_key, :string, allow_nil?: false
    attribute :received_at, :utc_datetime_usec, default &DateTime.utc_now/0
  end

  identities do
    identity :unique_idem, [:idempotency_key]
  end

  actions do
    defaults [:read]

    create :ingest do
      accept [:user_id, :progress_id, :result, :idempotency_key]
      change Ash.Changeset.after_action(fn cs, ev ->
        # enqueue async processing
        %{id: ev.id}
        |> KumaSanKanji.Workers.ProcessReviewEvent.new()
        |> Oban.insert()
        {cs, ev}
      end)
    end
  end

  policies do
    bypass actor_attribute_equals(:admin, true) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if expr(user_id == ^actor(:id))
    end

    policy action_type(:read) do
      authorize_if expr(user_id == ^actor(:id))
    end
  end
end
```

Oban worker to apply the event via the authoritative action:

```elixir
# lib/kuma_san_kanji/workers/process_review_event.ex

defmodule KumaSanKanji.Workers.ProcessReviewEvent do
  use Oban.Worker, queue: :reviews

  @impl true
  def perform(%Oban.Job{args: %{"id" => id}}) do
    ev = KumaSanKanji.Domain.get_review_event_by_id!(id)
    progress = KumaSanKanji.Domain.get_user_kanji_progress_by_id!(ev.progress_id, actor: %{id: ev.user_id})
    KumaSanKanji.Domain.record_review!(progress, %{result: ev.result}, actor: %{id: ev.user_id})
    :ok
  end
end
```

API: Expose a small JSON endpoint (controller or LiveAction) that calls `Domain.ingest_review_event/1` and returns `202 Accepted` with an event id.

## 3) Edge worker: verification and retries

- Sign edge → origin requests (HMAC or JWS) and verify at the endpoint; add a TTL to prevent replay.
- Require an `Idempotency-Key` header; store it in `review_events` identity to dedupe.
- Return 202 quickly; if the origin is slow, the edge retries with backoff.

## 4) CDN/edge caching for read-heavy content

- Version and publish Kanji datasets (or “study packs”) as JSON; serve with `Cache-Control: public, max-age=3600, stale-while-revalidate=86400`.
- Add a small Plug to add cache headers on safe endpoints.

```elixir
# lib/kuma_san_kanji_web/plugs/cache_headers.ex

defmodule KumaSanKanjiWeb.Plugs.CacheHeaders do
  import Plug.Conn
  def init(opts), do: opts
  def call(conn, _opts), do: put_resp_header(conn, "cache-control", "public, max-age=3600, stale-while-revalidate=86400")
end
```

## 5) Multi-region reads, single-writer pattern

- Keep writes (review ingest) in a primary region to avoid conflicts.
- Optionally add read replicas or a global cache for explore content; origin code stays the same.

## 6) Edge rate limiting & abuse filtering

- Rate-limit by IP/device at the edge; only forward clean traffic to the origin.
- Maintain server-side per-user limits and Ash policies for defense-in-depth.

## 7) On-device SRS computation (UX boost)

- Compute next-interval on device to show feedback immediately; still send events to the server for authoritative state.
- Server reconciles differences; treat client calculation as a hint.

## 8) Real-time hints via edge pub/sub

- Use a regional pub/sub or edge WebSocket service to fan out notifications (streaks, reminders) fast.
- Origin publishes compact events after jobs process.

## 9) A/B testing at the edge

- Assign variants at the edge (cookie); tweak UI or parameters for study flows.
- Include the variant in ingested events for analytics.

## 10) Precomputed study packs

- Nightly job creates small JSON bundles (e.g., JLPT5 set 1) and pushes to edge KV/cache.
- Client fetches the nearest copy for instant session start.

## Security & privacy notes

- Keep PII out of edge logs. Use opaque ids where possible.
- Verify signatures on edge POSTs; enforce TTL and idempotency.
- Keep Tidewave shell dev-only; do not expose command execution endpoints publicly.

## Ash alignment checklist

- Business logic in resource actions (e.g., `UserKanjiProgress.record_review`).
- Domain code interfaces for all external callers.
- Policies to enforce per-user access; use `actor` consistently.
- Identities for idempotency.

## Indexes & migrations

- `review_events(idempotency_key)` unique
- `user_kanji_progress(user_id, next_review_date)` composite
- `user_kanji_progress(user_id, kanji_id)` unique

## Rollout plan

1. Add `ReviewEvent` + worker; expose `/api/edge/reviews` (202 Accepted).
2. Ship the Service Worker queue; feature-flag its registration.
3. Introduce edge worker (or CDN function) for low-latency ingest with signatures.
4. Enable CDN caching on safe reads; roll out study packs.
5. Optional: multi-region reads and pub/sub.

## Validation

- Unit/property tests: SM-2 invariants; idempotency on ingest.
- Telemetry: count ingest events, processing latency, queue sizes.
- Synthetic checks from multiple regions for POST latency and cache hit rate.

---

If you want, we can scaffold `ReviewEvent`, the Oban worker, and a minimal `/api/edge/reviews` endpoint next, all via domain code interfaces.
