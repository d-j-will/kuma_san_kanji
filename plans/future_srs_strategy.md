# Future Strategy: The Hybrid AI-SRS System

## Overview
This document outlines the next generation of the KumaSanKanji Spaced Repetition System. It moves beyond the static SM-2 algorithm currently implemented to a **Hybrid AI-Driven Model**.

This system retains the satisfying progression structure of gamified systems (like WaniKani) but replaces rigid interval multipliers with an AI Probability Model (FCPM) to tailor the experience to the user's specific learning curve.

---

## 1. The "Rarity" Progression System (5 Tiers)

Instead of "Apprentice/Guru" terminology, we adopt an MMO-style "Rarity" system. This provides immediate, familiar visual feedback on how well a Kanji is known.

### Tier Definitions & Baseline Intervals
While the AI will optimize exact timings, these represent the *conceptual* milestones.

| Tier | Color | MMO Rank | Learning Stage | Baseline Interval | Behavior |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | **Grey** | **Common** | Initial Learning | Hours (4h → 8h) | High frequency. Item is volatile. |
| **2** | **Green** | **Uncommon** | Functional | Days (1d → 2d) | Short-term retention established. Unlocks related vocab. |
| **3** | **Blue** | **Rare** | Proficient | Weeks (1w → 2w) | Solid recall. Item requires infrequent maintenance. |
| **4** | **Purple** | **Epic** | Mastered | Months (1m → 4m) | Deep memory. Answer comes with little effort. |
| **5** | **Gold** | **Legendary** | Ascended | Never/Years | "Burned". Fluent. Removed from active rotation. |

### Visual Feedback
*   **UI:** Borders, progress bars, and card backgrounds will reflect these colors.
*   **Animations:** "Leveling up" a Kanji from Blue (Rare) to Purple (Epic) should have visual flair (particles, sound effects) to trigger dopamine reward.

---

## 2. The AI Engine: "Forgetting Curve" Prediction Model (FCPM)

We will transition from static multipliers (e.g., `Interval * 2.5`) to a probability-based scheduler.

### How It Works
1.  **Prediction:** For every Kanji, the model predicts the probability ($P$) that the user recalls it at time $t$.
2.  **Scheduling:** The system schedules the review for the moment $P$ drops to **90%** (configurable).
3.  **Inputs:**
    *   **Item Difficulty:** Stroke count, similarity to other known Kanji.
    *   **User History:** Average retention, time of day performance.
    *   **Global Stats:** How other users perform on this specific Kanji.

### The "Hybrid" Adjustment
The AI overrides the standard Rarity intervals:
*   **Accelerated Promotion:** If a user answers "Common" items correctly with < 1s latency consistently, the AI may skip them directly to "Uncommon" (Green) intervals, avoiding "junk reps".
*   **Safety Net:** If a user struggles with a specific "Rare" (Blue) item, the AI detects the struggle (latency, error patterns) and downgrades it to "Common" (Grey) faster than the standard penalty formula would.

---

## 3. Dynamic Gameplay Mechanics

### A. Dynamic Difficulty Clustering (The Sorting Hat)
When a user learns a *new* Kanji, its starting ease factor is not fixed.
*   **Visual Learners:** If the user excels at complex shapes, complex Kanji start with a higher hidden ease factor.
*   **Phonetic Learners:** If the user struggles with readings, Kanji with obscure readings start with a lower ease factor (more frequent initial reviews).

### B. "Ghost" Reviews (Leech Hunter)
*   **Definition:** Items that constantly bounce between **Common (Grey)** and **Uncommon (Green)** are "Leeches".
*   **Action:** The system identifies the "confusing pair" (e.g., 牛 vs. 午) causing the failure.
*   **Intervention:** It inserts a "Ghost Review" of the *confusing partner* immediately before or after the target item during a session to force discrimination learning.

### C. Optimal Session Scheduler
*   The system learns the user's circadian rhythm.
*   **Notification:** "Your brain is peaked for **Epic** reviews right now." (Sends notifications when the user is historically most accurate).
*   **Fatigue Watch:** If accuracy drops by >20% during a session, the system suggests stopping or switches to "Easy Mode" (reviewing high-confidence Gold/Purple items) to preserve morale.

---

## 4. Transition Strategy

### Phase 1: The UI Update (Cosmetic)
*   Update the current implementation to display the **Grey/Green/Blue/Purple/Gold** border/badge system.
*   Map current SM-2 intervals roughly to these tiers for display purposes.

### Phase 2: Data Harvesting
*   Begin logging detailed telemetry (latency, specific error types, time of day) without changing the algorithm. This trains the ML model.

### Phase 3: The AI Switch
*   Replace the `UserKanjiProgress` interval calculation with the FCPM inference.
*   Enable Dynamic Clustering for new items.
