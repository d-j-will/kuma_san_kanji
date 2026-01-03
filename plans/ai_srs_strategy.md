# AI-Enhanced SRS Requirements

## Overview
This document outlines the strategy for upgrading the current static SM-2 Spaced Repetition System to a dynamic, AI-driven Adaptive Learning System. The goal is to maximize retention while minimizing the time users spend on reviews (efficiency).

---

## 1. "Forgetting Curve" Prediction Model (FCPM)

### Description
Replace the heuristic-based SM-2 algorithm (fixed intervals/multipliers) with a predictive model that estimates the probability of recall ($P$) for a specific Kanji at any given time $t$.

### Implementation Strategy
*   **Model:** Gradient Boosted Decision Trees (XGBoost/LightGBM) or a specialized Spaced Repetition model like **HLR (Half-Life Regression)**.
*   **Input Features:**
    *   **Item Features:** Kanji stroke count, radical count, grade level, "confusability" score (embedding similarity to other items).
    *   **User Features:** Average accuracy, response latency history, retention rate.
    *   **History Features:** Previous interval, previous outcome, number of lapses.
*   **Output:** Predicted retention probability.
*   **Logic:** Schedule review when $P < 0.90$ (or user-configurable threshold).

### Measurable Outcomes
*   **Efficiency:** Reduce total review load by 20% while maintaining the same retention rate.
*   **Accuracy:** Predict pass/fail on the next review with > 80% AUC (Area Under Curve).

---

## 2. Optimal Review Session Scheduler (Reinforcement Learning)

### Description
An intelligent notification agent that learns the user's circadian rhythm and cognitive availability to suggest the *optimal* time for study.

### Implementation Strategy
*   **Model:** Contextual Multi-Armed Bandit or simple Reinforcement Learning agent.
*   **State:** Time of day, day of week, time since last session.
*   **Action:** Send Push Notification (Now, +1 hr, +4 hrs, etc.).
*   **Reward:** Session completion rate * Session accuracy.

### Measurable Outcomes
*   **Adoption:** Increase Daily Active Users (DAU) by 15%.
*   **Performance:** Users perform 10% better on reviews done at "Optimal" times vs. random times.

---

## 3. Dynamic Difficulty Clustering

### Description
Automatically categorize Kanji into difficulty clusters personalized to the user. If a user consistently fails visually complex characters, the system creates a "Visual Difficulty" cluster and lowers the starting Ease Factor for *new*, unlearned Kanji in that cluster.

### Implementation Strategy
*   **Technique:** K-Means Clustering or DBSCAN on user error patterns.
*   **Feedback Loop:** When a new Kanji is introduced, look up its cluster.
    *   *If Cluster = Hard:* Start Interval = 1hr.
    *   *If Cluster = Easy:* Start Interval = 1 day.

### Measurable Outcomes
*   **Onboarding:** Reduce "New Item" failure rate by 25%.
*   **Personalization:** System correctly identifies a user's "weakness type" (e.g., Phonetic vs. Visual) within 14 days.

---

## 4. "Ghost" Review Generation (Leech Killer)

### Description
Proactively prevent confusion by identifying "Leeches" (items the user keeps forgetting) and their "partners in crime" (similar items causing the confusion).

### Implementation Strategy
*   **Detection:** If user fails Kanji A (e.g., 牛 - Cow), look for visually similar Kanji B (e.g., 午 - Noon) in the database using embedding similarity.
*   **Action:** Insert Kanji B as a "Ghost" review in the *same* session, even if it wasn't due.
*   **Goal:** Force the user to discriminate between the two forms immediately.

### Measurable Outcomes
*   **Leech Reduction:** Reduce the number of "Leech" items (failed > 5 times) by 40%.
*   **Discrimination:** 90% accuracy on "Confusing Pairs" after 3 Ghost sessions.

---

## 5. Session Fatigue Detection

### Description
Real-time monitoring of user performance *during* a quiz to prevent "junk reps" (mindless clicking) caused by fatigue.

### Implementation Strategy
*   **Metrics:** Rolling average of Response Time (latency) and Error Rate over the last 10 items.
*   **Threshold:** If Latency increases by > 50% or Error Rate spikes:
    *   **Action A:** End session early ("You look tired, let's stop here").
    *   **Action B:** Switch to "Easy Review" mode (high-confidence items only) to boost morale.

### Measurable Outcomes
*   **Quality:** Increase "True Positive" rate of reviews (valid learning vs. lucky guesses).
*   **Retention:** Users who stop when "Fatigued" show higher return rates the next day.

---

## Roadmap

1.  **Phase 1 (Data Collection):** Implement **Session Fatigue Detection** metrics (latency logging) and **Ghost Review** logic (using existing similarity data). These require no ML training, just logic.
2.  **Phase 2 (Model Training):** Collect 1-3 months of user review data to train the **FCPM (Forgetting Curve)** model.
3.  **Phase 3 (Optimization):** Deploy **FCPM** to replace SM-2.
4.  **Phase 4 (Advanced):** Implement **Scheduler** and **Clustering** once user base is sufficient for data density.
