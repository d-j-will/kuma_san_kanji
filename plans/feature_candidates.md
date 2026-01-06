# Feature Candidates

This document tracks potential features for upcoming development cycles.

**Last Updated:** 2026-01-06

---

## 1. Audio Feedback - ✅ IMPLEMENTED
**Goal:** Enhance multimodal learning by adding audio pronunciation for Kanji.
**Why:** Critical for language retention and "Multimodal Reinforcement" (see `docs/novel.md`).
**Status:** ✅ **IMPLEMENTED** (see CHANGELOG.md)

**Implementation Complete:**
*   ✅ **TTS Integration:** Web Speech API implemented via `audio_feedback.js` hook
*   ✅ **UI:** "Speak" button added to `KanjiStrokeOrderComponent`
*   ✅ **Quiz Integration:** Auto-play on correct answers in QuizLive
*   ✅ **Voice Selection:** Prefers Japanese voice with fallback handling
*   ✅ **Comprehensive Testing:** Server-side events and UI component tests added

**Future Enhancements:**
*   Add pitch accent indicators for words
*   Support for pre-recorded native audio files
*   User preference for auto-play toggle
*   Audio for common word compounds (Issue #15)

## 2. Interactive Stroke Tracing - 🟡 FOUNDATION READY
**Goal:** Allow users to trace Kanji strokes on screen, converting passive viewing into active practice.
**Why:** Supports "Kinesthetic Learning" and active recall.
**Status:** 🟡 **Foundation exists, interaction layer not implemented** (GitHub Issue #22)

**Currently Available:**
*   ✅ Full stroke order animation via `kanji_stroke_order.js`
*   ✅ `KanjiStrokeOrderComponent` with replay, step-through controls
*   ✅ KanjiVG SVG integration with stroke-by-stroke highlighting
*   ✅ Brush and clean visual styles

**Remaining Work:**
*   ⚠️ **Canvas Layer:** Overlay a transparent drawing canvas on the KanjiVG SVG
*   ⚠️ **Stroke Detection:** Calculate stroke direction and accuracy against SVG paths
*   ⚠️ **Feedback:** Visual cues (green/red) for correct/incorrect strokes
*   ⚠️ **Accessibility:** Keyboard controls for tracing mode

**Estimated Effort:** 1-2 days
**Priority:** High (Issue #22 - opened 2026-01-03)

## 3. Detailed Answer Feedback - 🟡 DATA READY
**Goal:** Provide richer context when a user answers a quiz question.
**Why:** "Correct/Incorrect" is insufficient for deep learning. Users need to see *how* the Kanji is used.
**Status:** 🟡 **All data exists, UI integration needed** (GitHub Issue #23 - opened 2026-01-03)

**Available Data:**
*   ✅ Example sentences in `example_sentences` table
*   ✅ Common words in database
*   ✅ Kanji usage examples via `KanjiUsageExample` resource
*   ✅ Thematic groupings and educational contexts

**Implementation Plan:**
*   ⚠️ **Example Sentences:** Fetch and display 1-2 example sentences upon answering
*   ⚠️ **Common Words:** Show common compounds (Jukugo) containing the Kanji
*   ⚠️ **UI:** Expand the feedback section in `QuizLive` with toggle/expand
*   ⚠️ **Progressive Disclosure:** Show basic feedback first, allow expansion for details

**Estimated Effort:** 4-6 hours
**Priority:** High (Issue #23)
**Dependencies:** None - all data and infrastructure ready

## 4. Gamification & Social Features - 📋 PLANNED
**Goal:** Increase user retention through streaks, leaderboards, or "pet" mechanics.
**Why:** "Social Learning Integration" (see `docs/novel.md`).
**Status:** 📋 **Planned for future development**

**Current State:**
*   ✅ Basic user stats exist (accuracy, total reviews)
*   ✅ Progress tracking infrastructure via `UserKanjiProgress`
*   ⚠️ No gamification mechanics yet

**Ideas:**
*   **Streaks:** Daily login/review tracking with notifications
*   **Avatar:** Evolve the "Kuma-san" (Bear) mascot based on progress
*   **Leaderboards:** Optional opt-in ranking system
*   **Achievements:** Milestone badges (first review, 100 reviews, etc.)
*   **Daily Goals:** Customizable review count targets

**Priority:** Medium
**Estimated Effort:** 1-2 weeks for MVP
**Dependencies:** User settings infrastructure (already exists)
