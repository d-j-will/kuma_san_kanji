# Workspace Analysis & Recommendations

**Date:** 2026-01-06 (Updated)
**Project:** KumaSanKanji - Elixir/Phoenix Kanji Learning Application

## Executive Summary

This analysis tracks improvements across security, code quality, documentation, testing, and project organization. The application is well-structured using Ash Framework with strong domain-driven design principles.

**Major Progress Since Last Review (2025-01-27):**
- ✅ All critical security issues have been resolved
- ✅ CI/CD pipeline implemented with GitHub Actions
- ✅ Code quality tools configured (Credo, Dialyxir, ExCoveralls)
- ✅ Test coverage reporting enabled
- ✅ Health check endpoint added
- ✅ Cleanup of temporary scripts completed

---

## 🟢 Critical Security Issues - ALL RESOLVED ✅

### 1. ~~Overly Permissive User Read Policy~~ - ✅ FIXED
**Location:** `lib/kuma_san_kanji/accounts/user.ex:167-173`

**Status:** ✅ **RESOLVED**

**Previous Issue:** All users could read any user's data.

**Current Implementation:**
```elixir
policy action_type(:read) do
  # Admins can read any user
  authorize_if actor_attribute_equals(:admin, true)

  # Users can read their own user record
  authorize_if expr(id == ^actor(:id))
end
```

**Security Properties:**
- ✅ Users can only read their own data
- ✅ Admins can read all users for management
- ✅ Prevents privacy violations (email, settings, admin status exposure)
- ✅ Uses Ash's expression DSL to prevent SQL injection

---

### 2. ~~Missing Force SSL in Production~~ - ✅ FIXED
**Location:** `config/runtime.exs:52`

**Status:** ✅ **RESOLVED**

**Previous Issue:** HTTPS not enforced, vulnerable to MITM attacks.

**Current Implementation:**
```elixir
force_ssl: [hsts: true, rewrite_on: [:x_forwarded_proto]]
```

**Security Properties:**
- ✅ Enforces HTTPS for all connections
- ✅ Enables HSTS (HTTP Strict Transport Security)
- ✅ Protects against man-in-the-middle attacks
- ✅ Properly handles proxy headers (X-Forwarded-Proto)

---

### 3. ~~In-Memory Rate Limiting~~ - ✅ IMPROVED
**Location:** `lib/kuma_san_kanji_web/live/quiz_live.ex:528-550` & `lib/kuma_san_kanji/quiz/session.ex`

**Status:** ✅ **SIGNIFICANTLY IMPROVED**

**Previous Issue:** Rate limiting only in LiveView assigns (easily bypassed).

**Current Implementation:**
- Rate limit timestamps stored in `KumaSanKanji.Quiz.Session` GenServer with ETS
- Persists across page refreshes and browser tabs
- Survives LiveView crashes

**Security Properties:**
- ✅ Persists across page refreshes
- ✅ Shared across browser tabs (same ETS table)
- ✅ Survives LiveView crashes (GenServer manages state)
- ✅ Microsecond latency (faster than database)
- ⚠️ Lost on server restart (acceptable tradeoff for single-server deployment)
- ⚠️ Not distributed across multiple servers (not needed for current Fly.io deployment)

**Future Enhancement (Low Priority):**
For multi-server deployments, consider Redis or database-backed rate limiting. Current ETS implementation is production-ready for single-server deployments.

---

## ✅ High Priority Improvements - COMPLETED

### 4. ~~Clean Up Test Scripts Directory~~ - ✅ COMPLETED
**Status:** ✅ **RESOLVED**

The `test_scripts/` directory has been removed. Temporary debugging scripts have been cleaned up.

---

### 5. ~~Consolidate Admin Setup Scripts~~ - ✅ COMPLETED
**Status:** ✅ **RESOLVED**

Admin setup scripts have been consolidated and removed from the root directory.

---

### 6. ~~Improve README Documentation~~ - ⚠️ STILL NEEDS EXPANSION
**Location:** `README.md`

**Status:** ⚠️ **PARTIAL PROGRESS**

**Current State:**
- ✅ Basic project description with KanjiVG attribution
- ✅ Setup instructions present
- ⚠️ Missing architecture overview
- ⚠️ Missing links to documentation in `docs/` and `plans/`
- ⚠️ Missing development workflow guide

**Recommendation:**
Expand README to include:
- Project overview and unique value proposition
- Architecture (Ash Framework, domain-driven design)
- Links to documentation:
  - `AGENTS.md` for development guidelines
  - `DEPLOYMENT.md` for deployment
  - `docs/` folder for feature documentation
  - `plans/` folder for roadmap
- Quick start guide for contributors
- Development workflow (testing, linting, etc.)

---

### 7. ~~Add Test Coverage Reporting~~ - ✅ COMPLETED
**Location:** `mix.exs:103`

**Status:** ✅ **RESOLVED**

**Current Configuration:**
```elixir
{:excoveralls, "~> 0.18", only: :test}
```

Test coverage reporting is configured and functional.

---

## ✅ Medium Priority Improvements - MOSTLY COMPLETED

### 8. ~~Add CI/CD Configuration~~ - ✅ COMPLETED
**Location:** `.github/workflows/`

**Status:** ✅ **FULLY IMPLEMENTED**

**Current Workflows:**
- ✅ `fly-deploy.yml` - Build, test, and deploy pipeline
- ✅ `gemini-*.yml` - Automated issue triage and management
- ✅ PostgreSQL database setup in CI
- ✅ MeCab installation for furigana support
- ✅ KanjiVG asset ingestion and artifact upload
- ✅ Automated deployment to Fly.io on successful tests

**CI Pipeline Steps:**
1. Build and compile with warnings-as-errors
2. Run full test suite
3. Setup and build assets
4. Ingest KanjiVG SVG files
5. Deploy to Fly.io (London region)

---

### 9. ~~Add Code Quality Tools~~ - ✅ COMPLETED
**Location:** `mix.exs:101-102, 125`

**Status:** ✅ **FULLY CONFIGURED**

**Current Configuration:**
```elixir
{:credo, "~> 1.7", only: [:dev, :test], runtime: false}
{:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}

# Mix alias
quality: ["format --check-formatted", "credo --strict"]
```

**Tools Available:**
- ✅ Credo for static code analysis
- ✅ Dialyxir for type checking
- ✅ Format checking
- ✅ Mix alias for running quality checks

**Note:** Dependencies are declared but may need installation in local environment (`mix deps.get`).

---

### 10. Environment Variable Validation - ⚠️ PARTIAL
**Location:** `config/runtime.exs`

**Status:** ⚠️ **PARTIAL IMPLEMENTATION**

**Current State:**
- ✅ Required variables validated with descriptive errors
- ✅ Good error messages for missing variables
- ⚠️ No format validation (PORT range, POOL_SIZE positive, etc.)

**Recommendation:**
Add validation for:
- `PORT` (should be 1-65535)
- `POOL_SIZE` (should be positive integer)
- Database URL format validation
- Provide examples in error messages

---

### 11. ~~Add Health Check Endpoint~~ - ✅ COMPLETED
**Location:** `lib/kuma_san_kanji_web/router.ex:26`

**Status:** ✅ **IMPLEMENTED**

```elixir
get "/health", HealthController, :check
```

Health check endpoint is available for monitoring and load balancers.

---

### 12. Improve Error Handling - ⚠️ IN PROGRESS
**Location:** Throughout codebase

**Status:** ⚠️ **PARTIAL IMPLEMENTATION**

**Current State:**
- ✅ Structured error handling in SRS logic
- ✅ User-friendly flash messages
- ✅ Error logging in quiz sessions
- ⚠️ Could benefit from error tracking service integration

**Recommendation:**
- Standardize error message format across all LiveViews
- Consider error tracking service (Sentry, AppSignal, etc.)
- Implement `gettext` for internationalization of error messages
- Add structured logging with request correlation IDs

---

### 13. Database Indexes Audit - ⚠️ NEEDS REVIEW
**Location:** Migrations in `priv/repo/migrations/`

**Status:** ⚠️ **NOT AUDITED**

**Recommendation:**
- Review all common queries for missing indexes
- Ensure all foreign keys are indexed
- Add composite indexes for SRS due date queries
- Document index strategy in migration comments

---

### 14. API Documentation - N/A
**Status:** ℹ️ **NOT APPLICABLE**

This is a LiveView-only application without REST API endpoints. API documentation is not needed.

---

## 📋 Code Quality Improvements

### 15. Remove Debug Code from Production - ⚠️ ONGOING
**Location:** Multiple files

**Status:** ⚠️ **MOSTLY CLEAN, SOME ITEMS REMAIN**

**Items to Review:**
- ✅ User read policy debug code removed
- ⚠️ Check for any remaining `IO.inspect` calls in production code
- ⚠️ Review for any `Mix.env() == :dev` conditionals that could be feature flags

**Recommendation:**
- Grep for `IO.inspect`, `IO.puts`, `dbg()` in production code
- Use proper log levels consistently
- Consider feature flag system instead of environment checks

---

### 16. Standardize Logging - ⚠️ IN PROGRESS
**Location:** Throughout codebase

**Status:** ⚠️ **PARTIAL IMPLEMENTATION**

**Current State:**
- ✅ Some structured logging with Logger
- ⚠️ Inconsistent log message format
- ⚠️ No request correlation IDs

**Recommendation:**
- Add request IDs for tracing across LiveView sessions
- Standardize log message format
- Consider `LoggerJSON` for structured logs in production
- Ensure no PII in logs

---

### 17. Add Type Specifications - ⚠️ PARTIAL
**Location:** Throughout codebase

**Status:** ⚠️ **MINIMAL TYPESPECS**

**Recommendation:**
- Add `@spec` annotations to public functions
- Run Dialyzer to catch type errors
- Document complex types with `@type` definitions
- Start with critical modules (SRS logic, auth, quiz)

---

## 📚 Documentation Improvements

### 18. Add Architecture Documentation - ⚠️ NEEDS CREATION
**Recommendation:**
Create `docs/architecture.md` covering:
- Ash Framework patterns and domain structure
- Domain boundaries (Accounts, Kanji, Content, SRS, Quiz)
- Resource relationships and data flow
- Authentication flow with Auth0
- SRS algorithm overview (SM-2 implementation)
- Session management strategy
- Future: AI-driven FCPM system

---

### 19. Add Contributing Guidelines - ⚠️ NEEDS CREATION
**Recommendation:**
Create `CONTRIBUTING.md` with:
- Code style guidelines (follows AGENTS.md)
- Testing requirements (coverage, types of tests)
- PR process and review checklist
- Commit message format
- How to run quality checks (`mix quality`)
- How to run tests locally

---

### 20. Add Security Policy - ⚠️ NEEDS CREATION
**Recommendation:**
Create `SECURITY.md` with:
- How to report vulnerabilities responsibly
- Security best practices for contributors
- Known security considerations
- Authentication and authorization patterns
- Data privacy considerations

---

## 🧪 Testing Improvements

### 21. Add Integration Tests - ⚠️ PARTIAL
**Status:** ⚠️ **GOOD UNIT TESTS, FEW INTEGRATION TESTS**

**Current State:**
- ✅ 141 tests passing (5 properties, 136 examples)
- ✅ Unit tests for resources and SRS logic
- ⚠️ Limited end-to-end LiveView tests

**Recommendation:**
- Add integration tests for:
  - Complete quiz flow (login → select kanji → answer → review)
  - Authentication flows (Auth0 callback, logout)
  - SRS progression through multiple reviews
  - Rate limiting across sessions

---

### 22. Add Property-Based Tests - ✅ IN USE
**Status:** ✅ **IMPLEMENTED**

**Current State:**
- ✅ Using `stream_data` dependency
- ✅ 5 property-based tests passing

**Recommendation:**
- Expand property tests for SRS algorithm edge cases
- Test data validation boundary conditions
- Add property tests for furigana parsing

---

### 23. Add Performance Tests - ⚠️ NOT IMPLEMENTED
**Recommendation:**
- Add benchmarks for critical paths (quiz answer processing)
- Test database query performance (N+1 query detection)
- Load test quiz sessions with concurrent users
- Benchmark KanjiVG SVG loading and caching

---

## 🔧 Configuration Improvements

### 24. Development Seed Data - ✅ IMPLEMENTED
**Location:** `priv/repo/seeds.exs`

**Status:** ✅ **FULLY FUNCTIONAL**

**Current State:**
- ✅ Seeds 81 kanji with meanings, pronunciations, examples
- ✅ Seeds content domain (thematic groups, educational contexts)
- ✅ Works in development and test environments

**Future Enhancement:**
- Add sample users with different roles (regular user, admin)
- Add sample progress data for testing SRS features
- Document seed data structure in comments

---

### 25. Environment-Specific Configuration - ⚠️ NEEDS .env.example
**Status:** ⚠️ **MISSING .env.example FILE**

**Current State:**
- ✅ No secrets in version control
- ✅ Environment variables documented in runtime.exs comments
- ⚠️ Missing `.env.example` file for developers

**Recommendation:**
Create `.env.example` with:
```env
# Database
DATABASE_URL=postgres://postgres:postgres@localhost/kuma_san_kanji_dev

# Phoenix
SECRET_KEY_BASE=generate_with_mix_phx_gen_secret
PHX_HOST=localhost
PORT=4000

# Auth0
AUTH0_CLIENT_ID=your_client_id_here
AUTH0_CLIENT_SECRET=your_client_secret_here
AUTH0_DOMAIN=your_domain.auth0.com
AUTH0_REDIRECT_URI=http://localhost:4000/auth/user/auth0/callback

# Tokens
TOKEN_SIGNING_SECRET=generate_with_mix_phx_gen_secret
```

---

## 📊 Monitoring & Observability

### 26. Application Monitoring - ⚠️ BASIC TELEMETRY ONLY
**Status:** ⚠️ **TELEMETRY CONFIGURED, NOT EXPORTED**

**Current State:**
- ✅ Phoenix LiveView telemetry
- ✅ Ecto telemetry for database queries
- ⚠️ No custom business metrics
- ⚠️ No external monitoring service integration

**Recommendation:**
Add custom telemetry events for:
- Quiz session duration
- Answer submission rate and accuracy
- SRS algorithm execution time
- KanjiVG cache hit/miss ratio
- Rate limit violations

Consider integration with monitoring services (AppSignal, New Relic, etc.)

---

### 27. Structured Logging - ⚠️ PARTIAL
**Status:** ⚠️ **USES LOGGER, NOT STRUCTURED**

**Recommendation:**
- Implement structured logging with metadata
- Add correlation IDs for request tracing
- Log important business events (level up, mastery milestones)
- Ensure PII is scrubbed from logs
- Consider `LoggerJSON` for production

---

## 🚀 Performance Optimizations

### 28. Database Query Optimization - ⚠️ NEEDS PROFILING
**Recommendation:**
- Profile queries with `Ecto.Query` explain plans
- Review N+1 query patterns (use Ash's telemetry to identify)
- Ensure proper use of `Ash.load/2` for eager loading
- Add query result caching for frequently accessed kanji
- Monitor slow queries in production

---

### 29. Asset Optimization - ✅ CONFIGURED
**Status:** ✅ **OPTIMIZED**

**Current State:**
- ✅ esbuild minification in production
- ✅ Tailwind purging unused CSS
- ✅ Phoenix digest for cache busting
- ✅ KanjiVG SVGs cached in ETS

**Potential Enhancement:**
- Consider CDN for static assets in production
- Lazy load KanjiVG SVGs for non-visible kanji
- Optimize SVG file sizes if needed

---

## 📦 Dependency Management

### 30. Review Dependencies - ⚠️ NEEDS AUDIT
**Location:** `mix.exs`

**Status:** ⚠️ **NOT RECENTLY AUDITED**

**Recommendation:**
- Run `mix hex.audit` to check for security vulnerabilities
- Update to latest compatible versions
- Review if all dependencies are still needed
- Document why each major dependency is used (in comments or docs)

**Note:** mix.exs shows deprecation warning about `preferred_cli_env` that should be moved to `cli/0` function.

---

## 🎯 Current Priority Action Plan

### Immediate (Next 2 Weeks)

1. ⚠️ **Create .env.example file** (1 hour)
   - Document all required environment variables
   - Include example values and generation instructions

2. ⚠️ **Expand README.md** (2-3 hours)
   - Add architecture overview
   - Link to documentation folders
   - Add development workflow section
   - Include quick start guide

3. ⚠️ **Fix mix.exs deprecation warning** (30 minutes)
   - Move `preferred_cli_env` to `cli/0` function
   - Test with `mix test`, `mix coveralls`

4. ⚠️ **Audit database indexes** (2-4 hours)
   - Review common queries
   - Add missing indexes (especially SRS next_review_date queries)
   - Document indexing strategy

### Short Term (This Month)

5. ⚠️ **Create CONTRIBUTING.md** (2 hours)
   - Code style guidelines
   - Testing requirements
   - PR process

6. ⚠️ **Create SECURITY.md** (1 hour)
   - Vulnerability reporting process
   - Security best practices

7. ⚠️ **Add integration tests** (4-6 hours)
   - End-to-end quiz flow
   - Authentication flows
   - Rate limiting behavior

8. ⚠️ **Run dependency audit** (1-2 hours)
   - `mix hex.audit`
   - Update vulnerable packages
   - Remove unused dependencies

### Medium Term (Next Quarter)

9. ⚠️ **Create architecture documentation** (4-6 hours)
   - Document domain structure
   - Explain Ash patterns used
   - Document SRS algorithm

10. ⚠️ **Add custom telemetry** (3-4 hours)
    - Business metrics for quiz performance
    - SRS algorithm metrics
    - Cache performance metrics

11. ⚠️ **Consider monitoring service integration** (4-8 hours)
    - Evaluate AppSignal, Sentry, or New Relic
    - Implement if budget allows
    - Set up alerts for critical errors

12. ⚠️ **Environment variable validation** (2-3 hours)
    - Add format validation for PORT, POOL_SIZE
    - Improve error messages with examples

---

## 🎓 Feature Development Priorities

Based on GitHub Issues and planning documents:

### High Priority Features (Next 2-4 Weeks)

1. **Issue #23: Detailed Answer Feedback in Quiz** (4-6 hours)
   - Show example sentences after answering
   - Display common word compounds
   - Add contextual usage information
   - All data already exists in database

2. **Issue #13: Furigana Controls** (2-3 hours)
   - Add user preference: always/hover/after-answer
   - Persist preference in user settings
   - Update UI across explore and quiz pages

3. **Content Expansion** (ongoing)
   - Expand from 81 to 200+ kanji
   - Use existing grade kanji references
   - Automate ingestion where possible

### Medium Priority Features (1-2 Months)

4. **Issue #22: Interactive Stroke Tracing** (1-2 days)
   - Add canvas overlay on KanjiVG SVG
   - Implement stroke direction detection
   - Calculate accuracy against correct strokes
   - Provide visual feedback

5. **Audio Enhancements** (2-3 days)
   - Add pitch accent indicators
   - Improve voice selection logic
   - Add audio for common words

### Future Vision (3-6 Months)

6. **AI-Driven SRS System** (2-3 weeks)
   - Implement "Rarity" progression system (Grey/Green/Blue/Purple/Gold)
   - Start collecting telemetry data now for ML training
   - Replace SM-2 with FCPM (Forgetting Curve Prediction Model)
   - Add dynamic difficulty clustering

---

## Conclusion

**Major Achievements:**
- ✅ All critical security vulnerabilities resolved
- ✅ CI/CD pipeline fully operational
- ✅ Code quality infrastructure in place
- ✅ Test coverage reporting enabled
- ✅ Health checks and monitoring basics implemented

**Current Focus Areas:**
1. **Documentation:** README expansion, CONTRIBUTING.md, SECURITY.md, architecture docs
2. **Configuration:** .env.example, environment variable validation
3. **Testing:** More integration tests, property-based test expansion
4. **Features:** Issues #23, #13, and #22 from GitHub

**Overall Assessment:**
The KumaSanKanji application is in excellent shape with strong security posture, good test coverage (141 tests passing), and modern development practices. The main work ahead is documentation, feature development, and content expansion rather than foundational fixes.

The codebase demonstrates professional Elixir/Phoenix patterns with proper use of Ash Framework, domain-driven design, and comprehensive testing. Ready for continued feature development and production use.

---

**Last Updated:** 2026-01-06
**Next Review:** 2026-02-06 (1 month)
