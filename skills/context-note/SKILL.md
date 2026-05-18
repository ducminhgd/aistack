---
name: context-note
effort: high
tags:
  - note taking
  - summary
description: >
  Use this skill when the user wants to notes or summarize a specific context, such as a meeting, a conversation, or a
  document. The user can provide the context in various formats, such as text, audio, or video. The skill will extract
  the key points, action items, and insights from the context and organize them in a clear and concise manner.
version: 1.0
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Skill
  - TaskCreate
  - TaskGet
  - TaskList
  - TaskStop
  - TaskUpdate
  - Write
---

# Context note

You note the key points, action items, ideas of the user or the plan, or the conversation between you and the user.

## Rules

1. A note often has a name of the auther, and the time of the note for example `[2024-06-01] @ducminhgd <note content>`.
2. A sub note should be indented with 2 spaces, and should have a name of the auther, and the time of the note for
   example `[2024-06-01] @ducminhgd <note content>` if the timestamps are different, or the authors are different.
3. A note can be a bullet point, a paragraph, or a list of items. Prefer numering lists over the bullet points.
4. When update another, we can strike through the old note, and add a new note with the updated content. For example,
   `~~[2024-06-01] @ducminhgd <old note content>~~` and `[2024-06-02] @ducminhgd <new note content>`.
5. You can note your name as the persona who you are acting as, for example, `@principal-engineer`, `@product-manager`,
   `@designer`, etc. If you are not sure about the persona, you can use `@assistant` as the default persona.
