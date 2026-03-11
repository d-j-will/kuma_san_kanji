# AI/ML Strategic Requirements

## Overview
This document outlines the strategic integration of Artificial Intelligence and Machine Learning technologies into KumaSanKanji. These features align with the "Novel Teaching Methodologies" defined in `docs/novel.md`, specifically targeting **Micro-Context Learning**, **Kinesthetic Learning**, and **Multimodal Reinforcement**.

---

## 1. Micro-Story Generator (Contextual LLM)

### Description
Dynamically generate short reading passages (1-3 sentences) that strictly utilize:
1.  The specific target Kanji the user is currently learning.
2.  Kanji the user has *already* mastered (based on SRS data).
3.  Kana (Hiragana/Katakana).

This ensures "i+1" comprehensible input, eliminating the frustration of encountering unknown characters in static example sentences.

### Implementation Strategy
*   **Architecture:** Server-side integration via Ash Resource Action.
*   **Model:** External LLM API (OpenAI/Anthropic) or Fly.io GPU-hosted Llama 3.
*   **Prompt Engineering:** Inject user's `known_kanji_ids` list as constraints.
*   **Storage:** Cache generated stories in a `GeneratedContent` resource to reduce API costs.

### Measurable Outcomes
*   **Engagement:** Users spend 30% more time on the "Context" tab compared to static examples.
*   **Retention:** Reduce the "Fail" rate on first review of new Kanji by 15% due to better initial contextualization.
*   **Relevance:** 95% of generated sentences contain *zero* unknown Kanji (verified by automated text analysis tests).

---

## 2. Client-Side Handwriting Recognition (CNN)

### Description
Enable a "Production Mode" quiz where users draw the Kanji on a canvas instead of selecting multiple-choice answers or self-reporting. A client-side ML model predicts the character in real-time.

### Implementation Strategy
*   **Architecture:** Client-side TensorFlow.js or ONNX Runtime Web.
*   **Model:** Pre-trained model on ETL-9B (Japanese Handwriting Dataset). Quantized for web delivery.
*   **UX:** Real-time feedback loop. If confidence > 90%, auto-submit as correct. If < 50%, offer stroke hints.

### Measurable Outcomes
*   **Active Recall:** Users utilizing Handwriting Mode show a 20% higher retention rate at the 1-month SRS interval compared to "View & Reveal" users.
*   **Accuracy:** Model achieves Top-1 accuracy of > 85% and Top-3 accuracy of > 98% on user drawings.
*   **Performance:** Inference time < 100ms on average mobile devices to ensure UI responsiveness.

---

## 3. Smart Semantic Answer Validation (Embeddings)

### Description
Allow fuzzy semantic matching for meaning-based questions. If a Kanji means "Honor" and the user types "Prestige" or "Glory", the system accepts it as correct, shifting focus from keyword memorization to conceptual understanding.

### Implementation Strategy
*   **Architecture:** Server-side embedding comparison.
*   **Tech:** Elixir `Bumblebee` (Nx) running a small transformer model (e.g., `all-MiniLM-L6-v2`).
*   **Logic:** Compute Cosine Similarity between `User Input` and `Database Meanings`.
*   **Threshold:** Accept answer if Similarity > 0.85 (configurable).

### Measurable Outcomes
*   **User Frustration:** Reduce "False Negative" reports (where users felt they were right but marked wrong) by 80%.
*   **Typo Tolerance:** System correctly identifies 95% of minor typos (e.g., "Honnor" instead of "Honor") without regex maintenance.

---

## 4. Personalized Mnemonic Generator

### Description
Generate custom memory aids (stories/mnemonics) based on user-defined interests (e.g., "Sci-Fi", "Cooking", "History"). Deconstructs Kanji into radicals and weaves them into a narrative matching the user's persona.

### Implementation Strategy
*   **Architecture:** On-demand LLM calls triggered by user request (e.g., "I'm stuck" button).
*   **Data:** `User.interests` field tags.
*   **Radical Data:** Leverage `radicals` table to feed component meanings to the LLM.

### Measurable Outcomes
*   **Hard Kanji Resolution:** For "Leech" Kanji (items failed > 5 times), generating a personalized mnemonic results in a pass on the next review 70% of the time.
*   **Adoption:** 40% of active users configure an "Interest Persona".

---

## 5. Pronunciation "Shadowing" Grader

### Description
A "Listen & Repeat" feature where users mimic the native audio. The system analyzes the user's recorded audio and provides a similarity score, encouraging active speaking practice.

### Implementation Strategy
*   **Architecture:** Browser MediaRecorder API -> Phoenix Upload -> Server-side Analysis.
*   **Tech:** OpenAI Whisper (for transcription verification) + Audio Fingerprinting or DTW (Dynamic Time Warping) for pitch/pacing comparison.
*   **Feedback:** Visual "Pitch Graph" overlay comparing Native vs. User audio.

### Measurable Outcomes
*   **Speaking Confidence:** Users engaging with Shadowing complete 2x more audio-based reviews per session.
*   **Pronunciation Accuracy:** Detectable improvement in transcription accuracy of user speech over 30 days.

---

## Prioritization Roadmap

1.  **Phase 1 (Low Effort, High Value):** **Smart Semantic Validation**. Requires only backend logic changes and integration with Bumblebee/Nx. Solves an immediate UX pain point.
2.  **Phase 2 (Content Depth):** **Micro-Story Generator**. Enhances the core value proposition of the app.
3.  **Phase 3 (Interactive):** **Handwriting Recognition**. High "wow" factor but higher technical complexity (client-side model management).
4.  **Phase 4 (Personalization):** **Mnemonic Generator**. Good for power users/struggling items.
5.  **Phase 5 (Advanced):** **Pronunciation Grader**. High bandwidth/processing cost, best for a "Pro" feature.
