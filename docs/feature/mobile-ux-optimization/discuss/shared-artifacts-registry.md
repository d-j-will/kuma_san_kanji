# Shared Artifacts Registry: Mobile UX Optimization

## Purpose

Tracks all data values that appear in multiple places across the mobile learning journey. Every `${variable}` in mockups has a single source of truth and documented consumers. Untracked artifacts are the primary cause of horizontal integration failures.

---

## Registry

### current_route

- **Source of Truth**: Phoenix Router / LiveView socket assigns
- **Consumers**:
  - Bottom tab bar active tab indicator (all pages)
  - Header back navigation destination (group detail, teach, quiz)
- **Owner**: Router / Layout component
- **Integration Risk**: HIGH -- incorrect active tab breaks user orientation
- **Validation**: Active tab must match the current URL path prefix on every page load

### current_user

- **Source of Truth**: AshAuthentication session / `socket.assigns.current_user`
- **Consumers**:
  - Header avatar display
  - Bottom nav Profile tab (auth vs. guest state)
  - Learn dashboard (progress queries require user.id)
  - Group detail (learned kanji queries require user.id)
  - Quiz (SRS progress recording requires user.id)
  - Explore page My Notes section (auth-gated)
- **Owner**: AshAuthentication
- **Integration Risk**: HIGH -- missing user breaks all learning features
- **Validation**: Auth-gated pages redirect to sign-in when user is nil

### viewport_height

- **Source of Truth**: CSS `100dvh` (dynamic viewport height)
- **Consumers**:
  - Root layout body height
  - App shell grid container
- **Owner**: Root layout CSS
- **Integration Risk**: MEDIUM -- incorrect height causes overflow or dead zones
- **Validation**: Body fills viewport without scrollbar on app shell; content area scrolls independently

### groups

- **Source of Truth**: `ContentContext.get_all_thematic_groups/0`
- **Consumers**:
  - Learn dashboard group card list
  - Group detail page (individual group via find_group)
- **Owner**: Content domain
- **Integration Risk**: LOW -- standard Ash query
- **Validation**: Dashboard group count matches database thematic group count

### progress_map

- **Source of Truth**: `ContentContext.get_group_progress/2` per group
- **Consumers**:
  - Learn dashboard overall progress bar
  - Learn dashboard per-group progress bars
  - Learn dashboard per-group learned/total counts
- **Owner**: Content domain + SRS domain
- **Integration Risk**: MEDIUM -- must match group detail learned counts
- **Validation**: Sum of progress_map learned values equals dashboard total_learned

### reviews_due

- **Source of Truth**: `UserKanjiProgress.due_for_review/2` with `horizon_seconds: 0`
- **Consumers**:
  - Learn dashboard stats row count
  - Learn dashboard "Start Review" CTA visibility
- **Owner**: SRS domain
- **Integration Risk**: LOW -- single query, single consumer
- **Validation**: Count matches actual due_for_review query result

### study_streak

- **Source of Truth**: `UserKanjiProgress.user_stats/2` + `calculate_streak/1`
- **Consumers**:
  - Learn dashboard stats row
- **Owner**: SRS domain
- **Integration Risk**: LOW -- single consumer
- **Validation**: Streak matches consecutive review dates ending at today/yesterday

### group (individual)

- **Source of Truth**: `ContentContext` find_group (by slug or ID)
- **Consumers**:
  - Group detail page header and breadcrumb
  - Teach page breadcrumb and back link
  - Quiz page header
  - Quiz results "Back to {group}" button
- **Owner**: Content domain
- **Integration Risk**: MEDIUM -- slug must be consistent across all navigation paths
- **Validation**: Group slug in URL matches displayed group name on all pages

### kanji_list

- **Source of Truth**: `ContentContext.get_kanji_by_thematic_group/1`
- **Consumers**:
  - Group detail grid (displays all kanji in order)
  - Teach page total_kanji count (for "N of M" display)
  - Quiz pool source (learned kanji from this list)
- **Owner**: Content domain
- **Integration Risk**: HIGH -- ordering must match between grid and teach page positions
- **Validation**: Position N in teach page URL corresponds to kanji at index N-1 in kanji_list

### learned_kanji_ids

- **Source of Truth**: `UserKanjiProgress.get_user_kanji_progress/3` per kanji
- **Consumers**:
  - Group detail learned indicators (green border/checkmark)
  - Group detail learned count display
  - Group detail "all learned" state
  - Group detail next_unlearned_position calculation
- **Owner**: SRS domain
- **Integration Risk**: MEDIUM -- must match dashboard progress_map counts
- **Validation**: MapSet size of learned_kanji_ids equals progress_map learned count for group

### kanji (individual)

- **Source of Truth**: `ContentContext.get_kanji_at_position/2` (teach) or `Domain.get_kanji_by_offset/1` (explore)
- **Consumers**:
  - Teach page: character display, meaning tab, readings tab, examples tab
  - Explore page: character display, all sections
  - Quiz: character display, answer checking, feedback card
- **Owner**: Kanji domain
- **Integration Risk**: MEDIUM -- associations must be loaded (meanings, pronunciations, example_sentences)
- **Validation**: Kanji character, meanings, and pronunciations load successfully

### active_tab

- **Source of Truth**: LiveView socket assign in `teach_live.ex`, default `:character`
- **Consumers**:
  - Tab indicator highlighting
  - Tab content rendering (case statement)
  - Swipe gesture handler (determines next/prev tab)
  - Next/Back button labels
- **Owner**: TeachLive process
- **Integration Risk**: LOW -- single LiveView, single source
- **Validation**: Active tab indicator matches displayed content

### quiz_pool

- **Source of Truth**: `mount_quiz/2` in `group_quiz_live.ex` (learned kanji, shuffled)
- **Consumers**:
  - Current question kanji display
  - Total quiz items count
  - Progress bar calculation
  - Results pool for review mistakes
- **Owner**: GroupQuizLive process
- **Integration Risk**: MEDIUM -- must contain exactly learned kanji from group
- **Validation**: quiz_pool length equals learned_kanji_ids size for the group

### results

- **Source of Truth**: Socket assign in `group_quiz_live.ex`, accumulated per answer
- **Consumers**:
  - Running score display during quiz
  - Final summary accuracy calculation
  - Encouragement message selection
  - "Review Mistakes" button visibility
- **Owner**: GroupQuizLive process
- **Integration Risk**: LOW -- single process accumulation
- **Validation**: results.correct + results.incorrect equals answered question count

### safe_area_insets

- **Source of Truth**: CSS `env(safe-area-inset-*)` environment variables
- **Consumers**:
  - Bottom nav padding (safe-area-inset-bottom)
  - Header padding (safe-area-inset-top)
- **Owner**: Browser / OS (read-only)
- **Integration Risk**: MEDIUM -- requires viewport-fit=cover meta tag to activate
- **Validation**: Bottom nav fully visible above home indicator on notched devices

---

## Integration Checkpoints

| Checkpoint | Artifacts Involved | Validation |
|-----------|-------------------|------------|
| Dashboard-to-Group consistency | progress_map, learned_kanji_ids | Dashboard progress for group X equals group detail learned count for group X |
| Group-to-Teach ordering | kanji_list, position | Teach page position N shows same kanji as grid cell N |
| Teach-to-Quiz handoff | kanji, quiz_pool | "Mark learned" initializes SRS progress; quiz pool contains only learned kanji |
| Quiz-to-Results accumulation | results, per_kanji_results | results.correct + results.incorrect equals per_kanji_results length |
| Bottom nav-to-Route sync | current_route | Active tab matches URL path prefix on every navigation |
| Safe area consistency | safe_area_insets | Bottom nav padding consistent across all pages |
| Touch target consistency | All interactive elements | Every button, link, tab, and card meets 48x48px minimum on all pages |
