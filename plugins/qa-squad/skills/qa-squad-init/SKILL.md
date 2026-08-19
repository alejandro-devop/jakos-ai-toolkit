---
name: qa-squad-init
description: Prepares this project for the QA squad — creates docs/qa/ with the testing protocol, the findings register and an ENVIRONMENT.md filled in from how the project actually runs, including how the squad gets past a sign-in. Use when the user invokes /qa-squad-init, when they ask to install or set up the QA squad, or when a QA agent stops because docs/qa/ENVIRONMENT.md is missing.
---

# Skill: qa-squad-init

You leave this project ready for the `qa-planner → qa-tester → qa-triage`
session. Runs **once per project**, and again whenever the environment
changes.

Copying two files is the easy part. The work is **`ENVIRONMENT.md`**, and
inside it the three things this squad needs that a bug chain does not: how to
get past a sign-in, what test data may be created, and where the oracles are.

## Step 1: check whether it's already there

If `docs/qa/PROTOCOL.md` exists, **don't stomp on it** — it may carry the
user's adjustments with live sessions next to it. Say what's there and offer
either filling in only `ENVIRONMENT.md` or reinstalling everything, warning
that local adjustments are lost.

## Step 2: copy the protocol and the register

From `templates/` (next to this file) into `docs/qa/`: `PROTOCOL.md` as-is —
it's the method and doesn't depend on the project — and `REGISTER.md`, empty.

If the project keeps documentation elsewhere, ask and use that folder, then
say so: the agents look in `docs/qa/`.

## Step 3: reuse the map if one already exists

If the project already runs another chain with an `ENVIRONMENT.md` (a bug
chain, a feature chain), **read it and reuse what it already answers**:
addresses, what must not be run, real data, checks, gotchas. Copy it into
`docs/qa/ENVIRONMENT.md` and write nothing into the other chain's folder.

Then add the sections that only this squad needs, which that file will not
have.

## Step 4: the three sections that are yours

**Which browser, and how a session gets there.** If the module lives behind a
login, this decides whether the squad can work at all. **Nobody installs a
session** — agents don't type credentials, and one that mints itself a session
is what the permission rules exist to stop. The person signs in once
beforehand, in the browser you name here, and the agents inherit it. Name one
browser: the app's own or the person's through its extension, whichever they
are already signed into. If there is no way in at all, say so plainly:
everything behind the login comes back as manual steps, and that is a real
limit the user should know before the first session, not after it.

**Test data.** Testers write. Find out what is safe to create, what naming
makes an agent's litter recognisable later, and what must never be deleted —
in a shared store, somebody's draft looks exactly like leftovers.

**Where the oracles are.** The paths that state what correct means:
validation schemas, the layer that writes to storage, documents carrying
standing decisions, the test suites. Listing them once here saves every
session from hunting for them. Do not summarise what they say — just point at
them.

## Step 5: verify what you wrote

An address that doesn't answer, a command that doesn't exist or a made-up
identifier is worse than a blank: the agent takes it as true. What you
couldn't verify, write down as pending and say so.

Ask the user only what you can't find out yourself: which services they bring
up, what must not be touched, and whether anything breaks easily.

## Step 6: tell the user how it's used

Short, and with their part in it:

- `/qa-run <module>` runs a session: the planner writes charters, the testers
  execute them **one at a time**, the triage registers what survived.
- The squad **fixes nothing**. What comes out is a register.
- `/qa-dispatch <ID>` hands a bug to the chain that does fix it, if the
  project has one.
- The environment is theirs to bring up, and if there's a sign-in, theirs to
  open.
- What was left half-done in `ENVIRONMENT.md`, if anything was.

## What you do NOT do

- **You don't test and you don't register findings.** This only lays ground.
- **Don't invent the contents of `ENVIRONMENT.md`.** A wrong map sends the
  agent, fully confident, to a place that doesn't exist.
- **Don't build a way past the sign-in.** If the project has none, that's a
  finding to report to the user, not code for you to write.
- Don't change `PROTOCOL.md`. If this project needs a different rule, it goes
  in `ENVIRONMENT.md`.
- Don't install dependencies or bring up services to find things out.
