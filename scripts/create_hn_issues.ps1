# Requires: GitHub CLI (gh) authenticated to the repo.
# Usage: Open a PowerShell prompt at the repo root and run:
#   .\scripts\create_hn_issues.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Ensure-Label {
  param(
    [Parameter(Mandatory=$true)][string]$Name,
    [Parameter(Mandatory=$true)][string]$Color,
    [string]$Description = ''
  )
  $exists = gh label list --limit 200 | Select-String -SimpleMatch " $Name " -Quiet
  if (-not $exists) {
    Write-Host "Creating label '$Name'" -ForegroundColor Cyan
    gh label create $Name --color $Color --description $Description | Out-Null
  }
}

# Define labels to ensure exist
$labelsToEnsure = @(
  @{ name = 'area:quiz'; color = '66ccff'; desc = 'Quiz and SRS workflows' },
  @{ name = 'area:ux'; color = 'fbca04'; desc = 'User experience & UI' },
  @{ name = 'area:analytics'; color = '0366d6'; desc = 'Telemetry & analytics' },
  @{ name = 'area:content'; color = 'a2eeef'; desc = 'Content model & data' },
  @{ name = 'area:mobile'; color = 'd4c5f9'; desc = 'Mobile usability' },
  @{ name = 'area:integration'; color = 'bfd4f2'; desc = 'External integrations' },
  @{ name = 'area:audio'; color = 'c5def5'; desc = 'Audio & pitch accent' },
  @{ name = 'area:reader'; color = 'e99695'; desc = 'Reading mode and lookups' },
  @{ name = 'priority:p0'; color = 'b60205'; desc = 'Must do ASAP' },
  @{ name = 'priority:p1'; color = 'd93f0b'; desc = 'High priority' },
  @{ name = 'priority:p2'; color = 'f9d0c4'; desc = 'Medium priority' },
  @{ name = 'priority:p3'; color = 'fef2c0'; desc = 'Low priority' },
  @{ name = 'type:enhancement'; color = 'a2eeef'; desc = 'Feature request' },
  @{ name = 'type:bug'; color = 'd73a4a'; desc = 'Bug fix' }
)

foreach ($l in $labelsToEnsure) {
  Ensure-Label -Name $l.name -Color $l.color -Description $l.desc
}

# Issues payload
$issues = @(
  @{ 
    title = 'Global setting: Hide romaji (kana/kanji only)';
    labels = @('area:ux','area:content','priority:p1','type:enhancement');
    body = @'
Problem
Romaji can hinder reading skill development.

Acceptance Criteria
- A global user setting “Hide romaji” is available in Settings and on first-run.
- When enabled, quizzes and lists render kana/kanji only (no romaji hints).
- Setting persists per user and is respected across LiveViews and sessions.
- Default remains off for new users; onboarding explains the option.
Out of Scope
- Furigana controls (covered separately).
'@
  }
  ,@{
    title = 'Kana keyboard input: map romaji to kana in quizzes (no 1-4 keys)';
    labels = @('area:quiz','priority:p1','type:enhancement');
    body = @'
Problem
Current numeric answers reduce typing fluency and don’t train reading.

Acceptance Criteria
- Typing “ka” yields か, “e” yields え, etc., in input/readings quiz modes.
- Works with and without OS IME enabled; no duplicate characters produced.
- Keyboard navigation remains accessible (Tab, Enter); ARIA preserved.
- Fallback to on-screen input available on mobile.
'@
  }
  ,@{
    title = 'Vocabulary quiz: sentence-in-context prompts with reading reveal';
    labels = @('area:quiz','area:content','priority:p0','type:enhancement');
    body = @'
Problem
English gloss MCQs encourage shallow mapping and hurt retention.

Acceptance Criteria
- Add a quiz mode that uses an example sentence as the prompt.
- Show the target word highlighted; reveal furigana/readings after answer.
- Provide at least one example sentence per vocab item in data model.
- Avoid pure English-only prompts in default mode for vocab.
'@
  }
  ,@{
    title = 'Kanji quiz: include on/kun readings + example words on reveal';
    labels = @('area:quiz','area:content','priority:p1','type:enhancement');
    body = @'
Acceptance Criteria
- For each kanji item, reveal on-yomi and kun-yomi after user answers.
- Show 1–2 common example words per kanji with readings.
- Retain concise core meanings, de-emphasize English-only prompts by default.
'@
  }
  ,@{
    title = 'Add tooltips and brief descriptions for quiz modes';
    labels = @('area:ux','priority:p2','type:enhancement');
    body = @'
Acceptance Criteria
- Each quiz mode selector displays a short description on hover/tap.
- First-run shows a lightweight explainer for modes with “Don’t show again”.
- Content copy lives centrally for re-use and i18n.
'@
  }
  ,@{
    title = 'Improve set selection UX (select all in level, range select, persist state)';
    labels = @('area:ux','priority:p1','type:enhancement');
    body = @'
Acceptance Criteria
- “Select all in level” available for levels/JLPT bands.
- Shift-click (or touch equivalent) selects contiguous ranges.
- Collapsible groups remember open/closed and selection state.
'@
  }
  ,@{
    title = 'Default to beginner-friendly textbook font; keep stylized fonts optional';
    labels = @('area:ux','priority:p2','type:enhancement');
    body = @'
Acceptance Criteria
- Default font improves glyph clarity for new learners.
- Users can opt into stylized fonts via Settings.
- No layout regressions on mobile.
'@
  }
  ,@{
    title = 'Replace Google Analytics with privacy-friendly analytics or opt-out';
    labels = @('area:analytics','priority:p0','type:enhancement');
    body = @'
Acceptance Criteria
- GA is removed or fully disabled by default.
- Add Plausible or Simple Analytics, or rely on server-side metrics.
- Provide an explicit opt-out toggle if analytics remain.
- Update privacy policy/documents accordingly.
'@
  }
  ,@{
    title = 'Swap icons/labels: 字 for Kanji, 語 for Vocabulary';
    labels = @('area:ux','priority:p3','type:enhancement');
    body = @'
Acceptance Criteria
- Primary navigation and headings use 字 for “Kanji” and 語 for “Vocabulary”.
- No visual clashes with current iconography; accessible labels updated.
'@
  }
  ,@{
    title = 'Bug: Round total time always shows 0:00';
    labels = @('area:quiz','priority:p0','type:bug');
    body = @'
Steps to Reproduce
- Start any quiz round, answer several items, finish the round.
Expected
- Total elapsed time reflects actual duration in mm:ss.
Actual
- Always displays 0:00.
Acceptance Criteria
- Timer persists across LiveView patches and hydration.
- Unit/integration test covers elapsed time > 0.
'@
  }
  ,@{
    title = 'Guided onboarding (first-run flow)';
    labels = @('area:ux','priority:p1','type:enhancement');
    body = @'
Acceptance Criteria
- New users see a short tour explaining quiz modes and key settings (romaji, furigana, fonts).
- Offer “Start with N5” quick action and skip.
- Onboarding state stored per user; rerunnable from Settings.
'@
  }
  ,@{
    title = 'JLPT/Jōyō filters and per-level progress';
    labels = @('area:content','area:ux','priority:p1','type:enhancement');
    body = @'
Acceptance Criteria
- Users can filter content by JLPT level and Jōyō grade.
- Display per-level progress bars (items learned/reviewing).
- Filters affect quiz item pools and Explore lists.
'@
  }
  ,@{
    title = 'Furigana controls: always / hover / after-answer';
    labels = @('area:ux','area:content','priority:p1','type:enhancement');
    body = @'
Acceptance Criteria
- Global and per-quiz control for furigana display mode.
- “After-answer” reveals readings only on reveal state.
- Setting persists per user and is respected across views.
'@
  }
  ,@{
    title = 'Mobile: iOS tap status bar should scroll to top';
    labels = @('area:mobile','priority:p2','type:enhancement');
    body = @'
Acceptance Criteria
- On iOS Safari, tapping the status bar scrolls the primary content container to top.
- No regression for pull-to-refresh and safe area handling.
'@
  }
  ,@{
    title = 'Add audio playback and pitch accent on reveal for common words';
    labels = @('area:audio','area:content','priority:p2','type:enhancement');
    body = @'
Acceptance Criteria
- On reveal, show pitch accent notation and play audio if available.
- Provide mute setting and respect user’s reduced motion/audio preferences.
- Start with top N words; degrade gracefully when assets missing.
'@
  }
  ,@{
    title = 'Export/integration: Anki deck export and yomitan/takoboto add';
    labels = @('area:integration','priority:p2','type:enhancement');
    body = @'
Acceptance Criteria
- Export selected sets as Anki-compatible package or CSV (fields: expression, reading, meaning, sentence, audio).
- Support quick add from yomitan/takoboto via AnkiConnect/CSV drop.
- Document the workflow in README.
'@
  }
  ,@{
    title = 'Positioning: clarify “practice/reinforcement” and link immersion resources';
    labels = @('area:content','priority:p2','type:enhancement');
    body = @'
Acceptance Criteria
- Update landing and About copy to frame KSK as practice tool that complements immersion.
- Add links to resources like Natively and Narou indices.
'@
  }
  ,@{
    title = 'Reading mode: inline dictionary lookups and coverage indicators';
    labels = @('area:reader','area:integration','priority:p3','type:enhancement');
    body = @'
Acceptance Criteria
- Provide a basic reader that displays example texts with lookup support.
- Show coverage metrics by JLPT/Jōyō levels for the current text.
- Respect furigana and romaji settings.
'@
  }
  ,@{
    title = 'Writing practice: stroke order and handwriting mode';
    labels = @('area:quiz','area:content','priority:p3','type:enhancement');
    body = @'
Acceptance Criteria
- Show stroke order animations for kanji.
- Optional handwriting input practice mode with correctness feedback.
- Feature is opt-in and separate from core quiz flow.
'@
  }
  ,@{
    title = 'Scenario-based dialogues (restaurant, taxi, shopping)';
    labels = @('area:content','priority:p3','type:enhancement');
    body = @'
Acceptance Criteria
- Provide themed practice sets with short, realistic dialogues.
- Include audio (where available) and role prompts.
- Link out to real content for immersion follow-up.
'@
  }
)

Write-Host "Creating issues..." -ForegroundColor Green
foreach ($issue in $issues) {
  $labelsArgs = @()
  foreach ($label in $issue.labels) { $labelsArgs += @('--label', $label) }
  $title = $issue.title
  $body = $issue.body
  Write-Host "-> $title" -ForegroundColor Yellow
  gh issue create --title $title --body $body @labelsArgs | Write-Host
}

Write-Host "Done." -ForegroundColor Green
