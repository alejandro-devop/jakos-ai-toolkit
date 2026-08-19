---
name: qa-dispatch
description: Hands findings from the QA register to the chain that fixes them, and marks them dispatched with the id they got there. Use when the user invokes /qa-dispatch, or asks to send a finding, a bug or a QA result on to be fixed or queued.
---

# Skill: qa-dispatch

You move a finding from "somebody found this" to "somebody is going to fix
this". Nothing else: you don't investigate it, you don't fix it and you don't
re-judge it.

## What you can dispatch

Only findings of kind **bug** in state `new`. And that is the whole point of
the split:

- An **improvement** is not a defect. A chain that fixes bugs has nowhere to
  put it, and dispatching it there turns into someone arguing that it works
  as specified — which it does. It stays in the register until the user
  decides to build it.
- A **question** has no answer yet. Dispatching it means asking somebody to
  fix behaviour nobody has ruled on.

If the user names one of those, say why it doesn't go and offer what does.

## How

1. **Read the row and its entry** in the session file. What the receiving
   chain needs is what is already written: steps, expected with its oracle,
   actual, evidence, severity and frequency. If the entry doesn't stand on its
   own, stop — a thin dispatch buys back the investigation it was supposed to
   save.
2. **Find out where it goes.** If the project has a bug chain, its intake
   agent takes it (with `docs/bugs/` and a queue, that is `bug-reporter`). If
   there is none, say so: the finding stays in the register and the user
   decides.
3. **Hand it over whole**, saying it comes from a QA session and was
   reproduced — with the finding id and the session file so nothing gets
   re-transcribed. Pass along today's date, which those agents can't find out
   on their own.
4. **Mark the row** `dispatched` with the id it got there, so the two indexes
   can be read against each other later. **Re-read the register right before
   editing** and touch only your rows.

Several at once is fine, one handover each. Say which went and which didn't.

## Priority is not yours

You pass on severity and frequency as they are. Whoever receives it sets the
priority with their own scale — that is their trade, and translating between
the two scales here would produce two numbers that disagree about the same
defect.

## What you do NOT do

- **You don't fix, and you don't investigate the cause.**
- **You don't dispatch what you were not asked to.** No "and I sent the other
  four while I was at it".
- **You don't re-judge the finding.** If you think the triage got it wrong,
  say so to the user and leave it where it is.
