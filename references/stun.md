# STUN / TURN Server Guide

This document explains how to set up, configure, secure, deploy, and integrate a STUN/TURN server (using **coturn**) for WebRTC features in this application.

> TL;DR: Use STUN for public reflexive address discovery; use TURN (relay) as a fallback when direct P2P fails (symmetric NATs, corporate firewalls). Always provision TURN in production if you expect >~5–10% of users behind restrictive networks or need reliable file/data channel delivery.

---


## 1. Concepts Overview

| Term | Purpose |
|------|---------|
| STUN | Discovers public-facing IP:port (server never relays media) |
| TURN | Relays media when peers cannot reach each other directly |
| ICE  | Framework combining STUN, TURN, & host candidates to pick the best path |

### When You Need TURN

- Corporate firewall or symmetric NAT (no direct UDP path)
- Users behind double NAT (e.g. carrier‑grade NAT for mobile)
- Reliable DataChannels for quiz collaboration / real-time features
- File / media uploads peer-to-peer (future expansion)

**Rule:** Always provide at least one TURN server in the ICE server list; browsers only use it if needed.

---

## 2. Choosing coturn

`coturn` is the de facto open-source TURN/STUN server.

- Actively maintained
- TLS & DTLS support
- Long-term & ephemeral credential mechanisms
- Fingerprints, ALPN, TCP & UDP, Redis for auth (optional)

---

## 3. Network & Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 3478 | UDP/TCP  | STUN/TURN plaintext |
| 5349 | TLS/TCP (and DTLS/UDP) | TURN over TLS (recommended externally) |
| Relay Range | UDP (optionally TCP) | Actual media relay ports; define a narrow range |

**Recommended relay range:** `49160-49200` (adjust to scale). Open these in firewall (UDP). The smaller the range, the fewer concurrent relayed sessions you can handle.

### Firewall Checklist

- Allow inbound: 3478 (UDP/TCP), 5349 (TCP, and optionally UDP for DTLS)
- Allow inbound: relay UDP range (e.g., 49160-49200)
- Outbound: unrestricted (TURN must reach peers)

---

## 4. Credentials Strategy

| Mode | Pros | Cons | Use Case |
|------|------|------|---------|
| Static (long-term) user / pass | Simple | Credentials can leak; no rotation | Internal demos, dev |
| Ephemeral (TURN REST API style) | Time-limited, safer | Needs signing logic server-side | Production |

**Production Recommendation:** Use REST-style ephemeral credentials (HMAC-SHA1) generated server-side and returned through a Phoenix endpoint or embedded in a signed LiveView session.

Formula (standard TURN REST scheme):

```text
username = "<unix_epoch_expires>:<user_id_or_random>"
password = Base64.encode16(HMAC-SHA1(turn_secret, username))
```

Include `turn_secret` in server environment; do **not** expose it to clients.

---

## 5. Minimal Docker Deployment (Development)

Add to `docker-compose.override.yml` (example):

```yaml
services:
  coturn:
    image: coturn/coturn:4.6.2
    container_name: coturn
    restart: unless-stopped
    network_mode: host # For simplicity in dev on Linux; on Windows use explicit ports
    command: >-
      turnserver
        --no-cli
        --log-file=stdout
        --realm=kuma.local
        --listening-port=3478
        --tls-listening-port=5349
        --fingerprint
        --min-port=49160 --max-port=49200
        --use-auth-secret
        --static-auth-secret=${TURN_SECRET}
        --user-quota=12 --total-quota=1200
        --no-tlsv1 --no-tlsv1_1
    environment:
      - TURN_SECRET=dev_secret_change
```

If you cannot use `network_mode: host` (Windows/macOS), expose ports explicitly:

```yaml
    ports:
      - "3478:3478/udp"
      - "3478:3478/tcp"
      - "5349:5349/tcp"
      - "49160-49200:49160-49200/udp"
```

---

## 6. Native Install (Linux Bare Metal / VM)

```bash
apt update && apt install -y coturn
# Edit /etc/turnserver.conf (see below)
systemctl enable coturn
systemctl start coturn
```

Ensure `/etc/default/coturn` contains `TURNSERVER_ENABLED=1`.

---

## 7. Sample `turnserver.conf`

```conf
listening-port=3478
fingerprint
lt-cred-mech
# Use either long-term users OR shared secret (REST). Avoid both simultaneously in prod.
use-auth-secret
static-auth-secret=CHANGE_ME_LONG_RANDOM_BASE64
realm=webrtc.kuma.example
# TLS
cert=/etc/letsencrypt/live/webrtc.kuma.example/fullchain.pem
pkey=/etc/letsencrypt/live/webrtc.kuma.example/privkey.pem
# Harden
no-tlsv1
no-tlsv1_1
denied-peer-ip=0.0.0.0-0.255.255.255
allowed-peer-ip=0.0.0.0-255.255.255.255
# Relay range
min-port=49160
max-port=49200
# Logging (rotate externally)
log-file=/var/log/turn.log
# Limit abuse
user-quota=12
total-quota=1200
# Optional: restrict to UDP only (TCP fallback costs more CPU)
no-tcp-relay
# Performance
mobility # allow mobility per RFC 8016
```

---

## 8. TLS Certificates

Use a dedicated subdomain (e.g., `turn.kuma.example`). Acquire certificates with Let’s Encrypt (HTTP-01 or DNS-01). For coturn behind a reverse proxy, prefer direct TLS termination on coturn to support DTLS.

---

## 9. Generating Ephemeral Credentials in Elixir

Add a helper (domain-friendly module) – example:

```elixir
defmodule KumaSanKanji.Comms.TurnCreds do
  @ttl 3600 # 1 hour
  @secret Application.compile_env!(:kuma_san_kanji, :turn_secret)

  def generate(user_id) do
    expiry = DateTime.utc_now() |> DateTime.to_unix() |> Kernel.+(@ttl)
    username = "#{expiry}:#{user_id}"
    mac = :crypto.mac(:hmac, :sha, @secret, username) |> Base.encode64()
    %{username: username, credential: mac, ttl: @ttl}
  end
end
```

Configure in `runtime.exs`:

```elixir
config :kuma_san_kanji, :turn_secret, System.fetch_env!("TURN_SECRET")
```

Expose via a Phoenix (JSON) endpoint or LiveView assign:

```elixir
# Example controller action
creds = KumaSanKanji.Comms.TurnCreds.generate(current_user.id)
json(conn, %{ice_servers: [
  %{urls: ["stun:turn.kuma.example:3478"]},
  %{urls: ["turns:turn.kuma.example:5349"], username: creds.username, credential: creds.credential}
]})
```

---

## 10. Client Integration (Browser)

When creating a `RTCPeerConnection`:

```javascript
async function getICEServers() {
  const resp = await fetch('/api/ice');
  return (await resp.json()).ice_servers;
}

async function createPeer() {
  const iceServers = await getICEServers();
  const pc = new RTCPeerConnection({ iceServers });
  // Attach handlers
  return pc;
}
```

**Note:** Always include both `stun:` and `turns:` entries. Use `turns:` (TLS) externally for privacy & fewer blocks.

---

## 11. Security Hardening Checklist

- [ ] Use ephemeral credentials; rotate `turn_secret` periodically (invalidate after overlap window)
- [ ] Restrict relay ports & firewall everything else
- [ ] Enable TLS (5349) – browsers will still try UDP/DTLS if available
- [ ] Monitor bandwidth (TURN acts as a bandwidth sink)
- [ ] Log & alert on quota exceed events
- [ ] Consider fail2ban or rate-limiting external auth attempts
- [ ] Separate TURN server from main app host to avoid resource contention

---

## 12. Scaling & High Availability

| Strategy | Notes |
|----------|-------|
| Multiple TURN nodes + DNS round-robin | Easiest, stateless if using shared secret auth |
| Anycast / Geo DNS | Reduce latency by regional placement |
| Load balancer (L4) | Usually unnecessary; TURN already uses UDP/TCP directly |
| Autoscale | Monitor concurrent relayed sessions; CPU & bandwidth scale roughly linearly |

Because TURN does not share session state across nodes, horizontal scaling is straightforward with identical configs (same `static-auth-secret`).

---

## 13. Monitoring & Metrics

- Basic: tail logs for `ALLOCATE` and `REFRESH` events; count active allocations.
- Use `promtail`/`vector` to ship logs to Loki/Elastic.
- Bandwidth: track interface stats (`vnstat`, `ifstat`) or host-level metrics.
- Alert thresholds: sustained >70% of relay port capacity or network throughput.

### Quick Active Allocation Count

```bash
grep -c "session" /var/log/turn.log
```

(Adjust log parsing to your needs.)

---

## 14. Testing the Server

CLI tools:

```bash
# Basic STUN check (using stunclient / coturn's turnutils)
turnutils_stunclient turn.kuma.example -p 3478

# TURN allocate & relay test
turnutils_uclient -u test -w pass turn.kuma.example -p 3478 -t -T
```

Browser: Open dev tools -> `chrome://webrtc-internals` to inspect ICE candidates. You should see:

- `srflx` (server reflexive) from STUN
- `relay` from TURN (only if forced or direct fails)

Force TURN (debug) by blocking UDP locally or using `iceTransportPolicy: 'relay'`.

---

## 15. Production Deployment Steps Summary

1. Provision VM(s) (low latency regions) with static public IPs
2. Open firewall: 3478 UDP/TCP, 5349 TCP, relay UDP range
3. Install coturn / configure `turnserver.conf`
4. Obtain TLS certs (Let’s Encrypt) & reload service
5. Set `TURN_SECRET` in application environment (Fly.io / Docker secret)
6. Implement & expose ICE credentials endpoint in Phoenix
7. Update front-end to fetch ICE servers dynamically
8. Add monitoring & log shipping
9. Load test (simulate allocations, ensure capacity)
10. Document runbooks (rotate secret, scale node, renew cert)

---

## 16. Fly.io / Container Deployment Snippet

If deploying alongside app (separate app is recommended for scaling):

```toml
# fly.toml (separate app)
[env]
  TURN_MIN_PORT = "49160"
  TURN_MAX_PORT = "49200"
  TURN_SECRET = "<set via fly secrets>"

[[services]]
  internal_port = 3478
  processes = ["app"]
  protocol = "udp"
  [[services.ports]]
    port = 3478

[[services]]
  internal_port = 3478
  protocol = "tcp"
  [[services.ports]]
    port = 3478

[[services]]
  internal_port = 5349
  protocol = "tcp"
  [[services.ports]]
    port = 5349
```

Use a Dockerfile referencing `coturn` image and copying a `turnserver.conf` template.

---

## 17. Capacity Planning (Rule-of-Thumb)

| Metric | Approx Guideline |
|--------|------------------|
| One relayed HD video (720p) | 1–2 Mbps each direction |
| One TURN VM (2 vCPU / 1Gbps NIC) | ~200–300 concurrent light data/video sessions (monitor) |
| Port range size | >= (# concurrent relayed sessions * 2) headroom |

If your use case is mostly data channels (quiz synchronization), bandwidth needs are low; reliability matters more than throughput.

---

## 18. Troubleshooting Guide

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Only host candidates | STUN blocked / DNS fail | Check firewall & DNS for STUN domain |
| No relay candidates | TURN unreachable or auth failure | Verify ports, credentials, logs for ALLOCATE errors |
| High latency | TURN used unnecessarily | Ensure STUN reachable; inspect ICE candidate priority |
| TLS errors | Cert mismatch or outdated | Renew cert, check `realm` matches hostname |
| Allocation quota exceeded | user-quota too low | Increase `user-quota`/`total-quota` after sizing |

---

## 19. Future Enhancements

- Add a Phoenix endpoint to return multiple regional TURN servers
- Integrate metrics exporter (e.g., wrapper sidecar that parses logs -> Prometheus)
- Add rotating `turn_secret` with overlapping validity window
- Implement selective disabling of TCP relays if not needed

---

## 20. Quick Copy Checklist (Prod Rollout)

- [ ] DNS: `turn.kuma.example` -> public IP(s)
- [ ] Firewall rules open
- [ ] `turnserver.conf` validated
- [ ] TLS cert issued & auto-renew configured
- [ ] `TURN_SECRET` set & app redeployed
- [ ] Ephemeral credential endpoint live & tested
- [ ] Browser ICE candidate test passes (relay when forced)
- [ ] Monitoring/alerts configured
- [ ] Runbook documented

---

## References

- RFC 5389 (STUN), RFC 5766 (TURN), RFC 8445 (ICE)
- coturn project: [https://github.com/coturn/coturn](https://github.com/coturn/coturn)
- WebRTC ICE servers: [MDN Documentation](https://developer.mozilla.org/en-US/docs/Web/API/RTCIceServer)

---

Last updated: 2025-09-04 (update when modifying)
