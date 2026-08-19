---
name: qa-run
description: Runs a testing session over one module — plans the charters, executes them one at a time and registers what survives triage. Use when the user invokes /qa-run, or asks for a QA pass, a testing session or a bug sweep over a part of the product ("go over the catalogue", "test the sign-up form").
---

# Skill: qa-run

You conduct one testing session over the module the user named, delegating
each part to the agent whose job it is. You do not test yourself, and you do
not decide what enters the register: those are two different agents, on
purpose.

If the user named no module, ask. A session over "the whole product" produces
charters too wide to finish and a register nobody trusts.

## Before anything

Read `docs/qa/PROTOCOL.md` and `docs/qa/ENVIRONMENT.md`. If the second is
missing, stop and ask for `/qa-squad-init` to be run — without it the agents
spend their budget guessing addresses.

Check what the environment section says is needed and **say what is down
before spending a single agent**: a session whose services are not up produces
three testers reporting the same nothing.

If the module is behind a sign-in, **verify you are already in by opening the
page and reading it**, before spending anything. If the sign-in screen comes
back, stop and say so. Nobody here installs a session: agents don't type
credentials, and an agent that mints one for itself is what the permission
rules exist to stop. The person opens it beforehand, in the browser this
project's map names.

## 1. Plan

One `qa-planner`, with: the module, today's date (it can't find that out on
its own), and the path to `ENVIRONMENT.md`.

It comes back having written `docs/qa/SESSION-NNN-<module>.md` with the
oracles it found and three to six charters. **Read the charters before going
on.** Two things are worth stopping for: a charter with no oracle and not
labelled *questions expected*, and two charters covering the same ground. Both
are cheaper to fix now than after three testers have run.

## 2. Test, one at a time

One `qa-tester` per charter, **serially**. Each gets the session file path,
its charter number, and nothing else — the other charters bias it toward
ground already covered.

Serial is not a limitation to route around. Testers write data, and two of
them writing over the same store at once contaminate each other's readings:
a list that changes underneath, a record somebody else archived. That does not
lose a bug, it **invents** one, and an invented finding costs more than a
missed one. Only charters the planner marked read-only may overlap.

Between testers, say in one line what came back. If two in a row come back
empty, say so before launching the third: either that ground is solid or the
charters are not reaching it, and both are worth knowing early.

## 3. Triage

One `qa-triage` with the session file. It removes duplicates, separates
defects from decisions, and writes the rows into `docs/qa/REGISTER.md`.

## 4. Hand it back

Short, and useful without opening a single file:

- How many findings, split into bug, improvement and question.
- The worst one in one sentence, with its id.
- The questions, listed: those are the ones only the user can settle, and each
  answer is a business rule the project never wrote down.
- What the session did not cover.
- That `/qa-dispatch <ID>` sends a bug on to be fixed, and that nothing has
  been fixed here.

## What this skill does NOT do

- **It doesn't fix anything**, and it doesn't hand findings to another chain
  on its own. Dispatching is a separate command because it is the user's
  decision.
- **It doesn't bring services up.** If something is down, it says so and
  continues with whatever doesn't depend on it.
- **It doesn't run testers in parallel** to save time. See above.
- It doesn't commit.
