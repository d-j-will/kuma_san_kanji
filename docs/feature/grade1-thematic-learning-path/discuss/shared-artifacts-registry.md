# Shared Artifacts Registry: Grade 1 Thematic Learning Path

## Purpose

Tracks every data value that appears in multiple places across the learning path journey. Each artifact has a single source of truth. Untracked artifacts are the primary cause of integration bugs.

---

## Artifact Registry

### thematic_group_metadata

- **Source of truth**: `Content.ThematicGroup` Ash resource (table: `thematic_groups`)
- **Consumers**:
  - Group cards on `/learn` (name, description, color_code, icon_name, kanji count)
  - Group detail page header on `/learn/:group_slug` (name, description)
  - Teach step breadcrumb on `/learn/:group_slug/:position` (group name)
  - Quiz header on `/learn/:group_slug/quiz` (group name)
- **Owner**: Content domain
- **Integration risk**: LOW -- single Ash resource, read-only in this feature
- **Validation**: All pages referencing a group must load from `ThematicGroup` by the same ID. No hardcoded group names in templates.

### group_kanji_list

- **Source of truth**: `Content.KanjiThematicGroup` join resource (table: `kanji_thematic_groups`)
- **Consumers**:
  - Group detail kanji grid on `/learn/:group_slug` (ordered list of kanji in group)
  - Teach step navigation on `/learn/:group_slug/:position` (position X of Y, next/prev)
  - Quiz pool filter on `/learn/:group_slug/quiz` (which kanji IDs belong to this group)
  - Group progress calculation (count learned vs total in group)
- **Owner**: Content domain
- **Integration risk**: HIGH -- this join table defines group membership. If a kanji is missing from the join, it silently disappears from the group, the quiz, and the progress count.
- **Validation**: Count of `KanjiThematicGroup` records per group must match the curriculum reference (e.g., Numbers = 12). Automated test should verify expected counts.

### kanji_detail

- **Source of truth**: `Kanji.Kanji` resource with loaded relationships (table: `kanjis` + `kanji_meanings` + `kanji_pronunciations` + `kanji_example_sentences`)
- **Consumers**:
  - Teach step on `/learn/:group_slug/:position` (character, meanings, readings, sentences, stroke_count)
  - Quiz feedback on `/learn/:group_slug/quiz` (character, meanings, readings, sentences after answer)
  - Explore page on `/explore` (existing consumer -- same data)
  - Group detail kanji grid (character only, as preview)
- **Owner**: Kanji domain
- **Integration risk**: MEDIUM -- data is loaded via Ash `load:` which is reliable, but the teach step and quiz feedback must show identical data for the same kanji. If teach step loads meanings but quiz feedback does not, the learner sees inconsistent information.
- **Validation**: Both teach step and quiz feedback must use the same Ash query with `load: [:meanings, :pronunciations, :example_sentences]`. No separate or partial loads.

### learning_meta

- **Source of truth**: `Content.KanjiLearningMeta` resource (table: `kanji_learning_meta`)
- **Consumers**:
  - Teach step on `/learn/:group_slug/:position` (learning_tips, mnemonic_hints)
- **Owner**: Content domain
- **Integration risk**: LOW -- single consumer, graceful degradation when absent
- **Validation**: Teach step must handle nil learning_meta without error (tested in US-02 scenarios).

### user_kanji_progress

- **Source of truth**: `SRS.UserKanjiProgress` resource (table: `user_kanji_progress`)
- **Consumers**:
  - Group card progress badge on `/learn` ("X/Y learned")
  - Group detail learned/unlearned markers on `/learn/:group_slug`
  - "Continue Learning" link target (first kanji without progress in group)
  - Quiz pool filter on `/learn/:group_slug/quiz` (only quiz kanji with progress records)
  - Quiz answer recording (SRS `record_review` updates this resource)
  - Overall progress counter on `/learn` ("X/80 kanji learned")
- **Owner**: SRS domain
- **Integration risk**: HIGH -- this resource is the single source of "has this user learned this kanji?" A missing record means the kanji is treated as unlearned. A duplicate record (prevented by identity constraint) would break the count. The progress count on the group card and the learned markers on the group detail MUST agree.
- **Validation**: Progress counts must be derived from the same query: count of `UserKanjiProgress` records where `user_id = current_user` AND `kanji_id IN (group's kanji IDs via KanjiThematicGroup)`. The `unique_user_kanji` identity on UserKanjiProgress prevents duplicates.

### feature_flag

- **Source of truth**: FunWithFlags `:grade1_learning_path` flag
- **Consumers**:
  - Navigation component (show/hide "Learn" link)
  - `/learn` route (gate access)
  - All `/learn/*` sub-routes (inherit gate)
- **Owner**: Application configuration (admin toggleable at `/admin/feature-flags`)
- **Integration risk**: MEDIUM -- if the flag check is inconsistent (e.g., navigation checks flag but route does not), users see a link that leads to a 404.
- **Validation**: Both the navigation component and the LiveView mount must check the same flag with the same logic. Test: disable flag, verify nav link hidden AND direct URL access redirected.

### stroke_order_data

- **Source of truth**: KanjiVG SVG data loaded via `StrokeOrderEvents` module
- **Consumers**:
  - Teach step stroke order toggle on `/learn/:group_slug/:position` (Release 2, US-07)
  - Explore page stroke order toggle on `/explore` (existing consumer)
  - Quiz page stroke order toggle on `/quiz` (existing consumer)
- **Owner**: KanjiVG integration (existing)
- **Integration risk**: LOW -- same `StrokeOrderEvents` module reused across all consumers
- **Validation**: Stroke order for a given kanji character must produce identical animation regardless of which page triggers it. Reuse, do not duplicate.

---

## Integration Checkpoints

| Checkpoint | What to Verify | When |
|------------|---------------|------|
| Group membership consistency | `KanjiThematicGroup` count per group matches curriculum (Numbers=12, Directions=5, etc.) | After R3 seeding, before R1 launch |
| Progress count consistency | Group card badge on `/learn` matches learned count on `/learn/:group_slug` | After US-01 and US-05, regression test |
| Kanji data consistency | Teach step and quiz feedback show identical meanings/readings/sentences | After US-02 and US-04, regression test |
| Feature flag consistency | Nav link visibility and route access agree when flag is on/off | After US-01, regression test |
| SRS integration | `record_review` in group quiz updates the same `UserKanjiProgress` record visible in group progress | After US-04, regression test |
