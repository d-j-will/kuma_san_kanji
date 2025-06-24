---
marp: true
theme: rose-pine-moon
---

# *AI Tools with GitHub Copilot*

---

## Learnings 1

* Help the LLM - Use the right mode Ask/Edit/Agent
  
  * Ask mode less expensive (generally not rate limited)
  * Edit mode great for editing lots of files without requiring the LLM to deeply understand the codebase. Simple refactoring etc.
  * Agent mode where the fun starts
    * MCP and other tools
  
---

## Learnings 2
  
* Plans
  * PRD
    * [Initial PRD](../../README.md)
  * Per Feature - use the LLM for help if needed to start or iterate
    * [Stroke Order Feature](../plans/stroke_order.md)

---

## Learnings 3

* Instructions
  * General copilot instructions for working with any code
    * [Copilot Instructions](../.github/copilot-instructions.md)
  * Find out if your language/ecosystem/library/framework has an llms.txt already
    * [Ash Framework Rules/Instructions](../.github/instructions/ash-rules.instructions.md)

* References
  * Use to add extra specific context to really focus the LLM
    * [Grade 1 Kanji](../references/grade1kanji.md)

---

## What I would do differently next time

* Create a skeleton app using the framework I've chosen manually. Usually a 2 minute job, sets the scene for the LLM to work on more accurately.
* Go and find and/or write yourself any rules/instructions for tech you're planning to use. e.g. Ash Phoenix
* Switch between Ask and Agent mode more frequently.
* Get the app deployable early as possible. Stand up the **create new project**
* Pick your database early and integrate.
* Integrate Auth next, (if you're going to use it)
