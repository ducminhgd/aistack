---
name: adr-interview
description: Interview the user about an architecture decision, then write an ADR. Use when asked to create or document an ADR.
version: 1.0
tools:
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - Edit
  - EnterPlanMode
  - ListMcpResourcesTool
  - ReadMcpResourceTool
  - Skill
  - TaskCreate
  - TaskGet
  - TaskList
  - TaskStop
  - TaskUpdate
  - WebSearch
  - WebFetch
  - Write
---
# ADR Interview

1. If the user provides a document (techinical design document, or requirements document), follow the document to interview. If user does not provide, ask them if they forgot, otherwise, ask them more questions in the next step.
2. Ask those basic questions to clarify (if there is anything unclear), included but not limited:
    1. What is the problem, the issue that this ADR proposed to sovle?
    2. What is its goals?
    3. What is the current situation? Is there any constraints? What is its scopes?
    4. What are the proposed solutions or approaches?s
    5. What is the architectural decision? Pros and cons? Is there any consequences, or risks, or technical debts?
    6. If there is any part above unclear or not enough information, you can use AskUserQuestion to clarify it deeper.
3. Using the template to fill the answers.
    1. Default. If the ADR is short, use the template [templates/adr-madr.md](templates/adr-madr.md).
    2. Else, use the template [templates/adr-mgd.md](templates/adr-mgd.md).
4. Default ADRs are located in `docs/adr/` directory. If the user asks to publish the ADR to Confluence, or Google Drive, or some cloud service, or save the ADR as a PDF file, a HTML file, remember to numbering the headings, follow this format

    ```
    1.
    1.1. 
    1.1.1.
    ```

5. You can add diagrams or images to visualize, or to help the other easier to understand.
6. Each ADR has it ID, using format `ADR-NNNN`, where `N` is a digit. Examples:
   1. File names: `ADR-NNNN-<summmary>.md`
   2. Title in the file `# ADR-NNNN <Summary>`
7. If a ADR superseds one or multiple ADRs, mention them in the summary, and go through each of those ADRs to update their statuses. You can use the second-brain syntax to mention them, for example: `[[ADR-100 Low latency API improvement]]`.