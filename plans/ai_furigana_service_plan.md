# AI/ML Furigana Generation Service Plan

## Overview
This document outlines a plan to implement a highly accurate, AI/ML-powered Furigana generation service using Python, to be integrated as a side-car with the KumaSanKanji Elixir application. This approach aims to address the complexities of Kanji-Kana splitting (e.g., `行きます` -> `<ruby>行<rt>い</rt></ruby>きます`) and contextual reading disambiguation, which are challenging for simpler rule-based tokenizers.

## Goals
*   Generate precise partial furigana, where only the Kanji portion of a mixed Kanji-Kana word receives ruby tags.
*   Improve accuracy of reading predictions for ambiguous Kanji based on sentence context.
*   Provide a scalable and maintainable solution for Japanese NLP tasks.
*   Decouple heavy NLP processing from the core Elixir application.

## Architecture: Python Side-Car Service

The proposed solution involves developing a separate Python web service that exposes an API for Furigana generation. The Elixir application will communicate with this service via HTTP.

```
+------------------+     HTTP Request    +------------------------+
|  Elixir App      | <-----------------> |  Python Furigana Service |
| (KumaSanKanji)   |                     |  (FastAPI/Flask + NLP) |
|                  |     JSON Response   |                        |
+--------^---------+                     +----------^-------------+
         |                                          |
         | (Calls `KumaSanKanji.NLP.Furigana`)      | (Uses SudachiPy/Transformers)
         v                                          v
      (Ruby Tag HTML)                           (Parsed Sentence Data)
```

## Python Furigana Service Details

### 1. Technology Stack
*   **Web Framework:** FastAPI (recommended for performance and ease of use) or Flask.
*   **Morphological Analyzer:** `SudachiPy` (preferred over MeCab for modern Japanese and fine-grained tokenization/dictionary options).
*   **Deep Learning NLP (Optional, for higher accuracy/context):** Hugging Face `transformers` library with a pre-trained Japanese language model (e.g., Japanese BERT variants) if contextual reading disambiguation and advanced Kanji-Kana alignment beyond `SudachiPy`'s direct output are required.

### 2. API Design
*   **Endpoint:** `/furigana` (e.g., `POST /furigana`)
*   **Request Body (JSON):**
    ```json
    {
      "sentence": "日本語を勉強しています。"
    }
    ```
*   **Response Body (JSON):**
    ```json
    {
      "tokens": [
        {"surface": "日本", "reading": "にほん", "is_kanji_only": true, "furigana_html": "<ruby>日本<rt>にほん</rt></ruby>"},
        {"surface": "語", "reading": "ご", "is_kanji_only": true, "furigana_html": "<ruby>語<rt>ご</rt></ruby>"},
        {"surface": "を", "reading": "を", "is_kanji_only": false, "furigana_html": "を"},
        {"surface": "勉強", "reading": "べんきょう", "is_kanji_only": true, "furigana_html": "<ruby>勉強<rt>べんきょう</rt></ruby>"},
        {"surface": "しています", "reading": "しています", "is_kanji_only": false, "furigana_html": "しています"},
        {"surface": "。", "reading": "。", "is_kanji_only": false, "furigana_html": "。"}
      ],
      "processed_sentence_html": "<ruby>日本<rt>にほん</rt></ruby><ruby>語<rt>ご</rt></ruby>を<ruby>勉強<rt>べんきょう</rt></ruby>しています。"
    }
    ```
    *   **For partial furigana (e.g., `行きます` -> `<ruby>行<rt>い</rt></ruby>きます`):**
        The token structure in the JSON response would be more granular, potentially like:
        ```json
        {
          "tokens": [
            {"text": "行", "ruby": "い"},
            {"text": "きます", "ruby": null}
          ],
          "processed_sentence_html": "<ruby>行<rt>い</rt></ruby>きます"
        }
        ```
        This would require the Python service to handle the Kanji-Kana splitting logic itself.

### 3. Core Logic (Python)
*   Receive `sentence`.
*   Initialize `SudachiPy` (or other chosen analyzer) with appropriate dictionary (e.g., `full` dictionary for detailed analysis).
*   Tokenize `sentence` into `SudachiPy` `Morpheme` objects.
*   Iterate through morphemes:
    *   For each morpheme, extract its `surface`, `reading`, and `part_of_speech`.
    *   **Kanji-Kana Splitting Logic:** Implement (or use a library for) a robust algorithm to align the `reading` with the `surface` to determine what part of the `reading` corresponds to the Kanji characters and what corresponds to any Hiragana/Katakana in the `surface`. This is the most complex step.
        *   Heuristic approach: Compare `surface` and `reading` character by character.
        *   Advanced approach: Use `SudachiPy`'s detailed output or a trained ML model for character-level alignment.
    *   Construct the `<ruby>` HTML string for each token based on this analysis.
*   Return the processed HTML and/or structured token data.

## Elixir Integration Details

### 1. `KumaSanKanji.NLP.Furigana` Module Modification
*   Change `parse_sentence/1` to:
    *   Make an HTTP `POST` request to the Python service endpoint (`/furigana`) with the Japanese sentence as JSON.
    *   Handle `Req` client setup (connection pooling, timeouts).
    *   Parse the JSON response.
    *   Extract the `processed_sentence_html` from the response.
    *   Implement error handling (service unavailability, invalid response).

### 2. Configuration
*   Add a new application environment variable for the Python service URL (e.g., `:python_furigana_url`).
*   Example: `config :kuma_san_kanji, :python_furigana_url, "http://localhost:8000/furigana"`

## Deployment Strategy

### Option 1: Separate Fly.io App (Recommended)
*   Deploy the Python service as its own Fly.io application.
*   Link it to the Elixir app via a private network.
*   The Elixir app's config will point to the Python app's internal IP/hostname.

### Option 2: Multi-Process Docker Container
*   Modify the Elixir `Dockerfile` to install Python and all its dependencies.
*   Use a process manager (e.g., `supervisord`, `foreman`, `s6-overlay`) to run both the Elixir release and the Python FastAPI/Flask app within the same Docker container.
*   This simplifies deployment but couples the two environments more tightly.

## Future Enhancements
*   **Contextual Reading Disambiguation:** Fine-tune a Japanese BERT model to predict the most likely reading of ambiguous Kanji based on the surrounding sentence context.
*   **User Preferences:** Allow users to toggle furigana display levels (e.g., all Kanji, only difficult Kanji).
*   **Custom Dictionaries:** Allow users to add custom words/readings to influence the furigana output.

## Trade-offs
*   **Increased System Complexity:** Introducing a second language stack and inter-service communication.
*   **Deployment Overhead:** Requires managing an additional service or a more complex Docker image.
*   **Initial Setup Time:** Setting up the Python environment and potentially training models.
*   **Network Latency:** HTTP requests add latency, but this can be mitigated by keeping services close (e.g., on the same Fly.io private network).

This plan outlines a robust path forward for a truly advanced Furigana generation feature.
