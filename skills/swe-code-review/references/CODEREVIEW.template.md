# Code Review — <SHORT DESCRIPTION OR PR/TICKET TITLE>

**Date:** YYYY-MM-DD HH:mm UTC  
**Reviewer:** <Name / Claude>  
**Target:** <file(s), PR link, branch, or commit>  
**Requested by:** <Author name>

---

## Verdict

> **[APPROVED | CHANGES REQUESTED | BLOCKED]**

---

## Summary

_One paragraph describing what the code does, the overall quality assessment, and the single most important concern (if any)._

---

## Findings

_Omit any dimension that has no findings. Do not write "No issues found" as a placeholder._

### Critical

<!-- CRITICAL: Data loss, security vulnerability, broken contract, crash in prod — must fix before merge -->

#### [CRITICAL] <Title>

**File:** `path/to/file` (line X–Y)  
**Issue:** _What is wrong and why it matters._  
**Suggestion:**

```language
// suggested fix
```

---

### Major

<!-- MAJOR: Correctness issue, significant design smell, untestable logic — should fix before merge -->

#### [MAJOR] <Title>

**File:** `path/to/file` (line X–Y)  
**Issue:** _What is wrong and why it matters._  
**Suggestion:**

```language
// suggested fix
```

---

### Minor

<!-- MINOR: Style, naming, readability, non-urgent refactor — fix when convenient -->

#### [MINOR] <Title>

**File:** `path/to/file` (line X–Y)  
**Issue:** _What is wrong._  
**Suggestion:** _Specific change to make._

---

### Nits

<!-- NIT: Cosmetic preference — no action required -->

- `path/to/file` line X — _nit comment_

---

## What's Good

_Concrete things the author did well. Not filler — only call out genuine strengths._

- 
- 

---

## Next Steps

_Prioritised list of what to address first._

1. 
2. 

---

## Dimensions Assessed

| Dimension        | Status                          |
| ---------------- | ------------------------------- |
| Correctness      | ✅ / ⚠️ / ❌ _brief note_      |
| Security         | ✅ / ⚠️ / ❌ _brief note_      |
| Loose Coupling   | ✅ / ⚠️ / ❌ _brief note_      |
| Testability      | ✅ / ⚠️ / ❌ _brief note_      |
| Readability      | ✅ / ⚠️ / ❌ _brief note_      |
| Performance      | ✅ / ⚠️ / ❌ _brief note_      |
| Consistency      | ✅ / ⚠️ / ❌ _brief note_      |
