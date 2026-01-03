# Feature Candidates

This document tracks potential features for upcoming development cycles.

## 1. Audio Feedback (High Priority)
**Goal:** Enhance multimodal learning by adding audio pronunciation for Kanji.
**Why:** Critical for language retention and "Multimodal Reinforcement" (see `docs/novel.md`).
**Status:** Planned (`plans/audio_plan.md`), but not implemented.
**Implementation Plan:**
*   **TTS Integration:** Use Web Speech API (Browser TTS) as a lightweight first step.
*   **UI:** Add "Play Audio" button to Quiz and Kanji Detail pages.
*   **Logic:** Trigger audio automatically on correct answers (user preference).
*   **Future:** Support for pre-recorded native audio files.

## 2. Interactive Stroke Tracing
**Goal:** Allow users to trace Kanji strokes on screen, converting passive viewing into active practice.
**Why:** Supports "Kinesthetic Learning" and active recall.
**Status:** Basic stroke order animation exists (`KanjiStrokeOrderComponent`), but no user interaction.
**Implementation Plan:**
*   **Canvas Layer:** Overlay a transparent drawing canvas on the KanjiVG SVG.
*   **Stroke Detection:** Calculate stroke direction and accuracy against the SVG paths.
*   **Feedback:** Visual cues for correct/incorrect strokes.
*   **Tech:** Enhance `KanjiStrokeOrderComponent` with Javascript hooks.

## 3. Detailed Answer Feedback
**Goal:** Provide richer context when a user answers a quiz question.
**Why:** "Correct/Incorrect" is insufficient for deep learning. Users need to see *how* the Kanji is used.
**Status:** Data (Example Sentences, Common Words) exists in the database but is not shown in Quiz feedback.
**Implementation Plan:**
*   **Example Sentences:** Fetch and display 1-2 example sentences upon answering.
*   **Common Words:** Show common compounds (Jukugo) containing the Kanji.
*   **UI:** Expand the feedback section in `QuizLive`.

## 4. Gamification & Social Features
**Goal:** Increase user retention through streaks, leaderboards, or "pet" mechanics.
**Why:** "Social Learning Integration" (see `docs/novel.md`).
**Status:** Basic user stats exist.
**Ideas:**
*   **Streaks:** Daily login/review tracking.
*   **Avatar:** Evolve the "Kuma-san" (Bear) mascot based on progress.
