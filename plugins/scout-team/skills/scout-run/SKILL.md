---
name: scout-run
description: Sends the scouts through a module one at a time, each on an errand as one of the people who really use it, and has the lead verify what they missed and write the suggestions. Use when the user invokes /scout-run, or asks for a usability pass, a fresh-eyes review or suggestions on how a part of the product could be easier to use.
---

# Skill: scout-run

You run one scouting pass over the module the user named. You do not scout
yourself and you do not verify: those are two agents, and keeping them apart
is the method.

If the user named no module, ask. "The whole product" produces errands too
vague to stumble over anything in particular.

## Before anything

Read `docs/scout/PROTOCOL.md` and `docs/scout/ENVIRONMENT.md`. If the second
is missing, stop and ask for `/scout-team-init` to be run — most of what a
scout needs is in there, and the scouts can't read it themselves.

Then, and this is not optional:

- **Check the services are up.** A scout can't report on a screen that never
  loaded, and it can't tell "this product is confusing" from "nothing
  rendered". If something is down, say so and stop.
- **Check that a screenshot actually comes back.** Open a tab and take one.
  This whole team rests on looking, and in some setups the window is hidden
  and screenshots come back empty. Finding that out now costs one turn;
  finding out after three scouts costs three scouts.
- **If there's a sign-in, the user opens it now.** Say so and wait. Agents
  don't type credentials, and a scout that lands on a login screen will report
  the login screen.

## 1. Write the errands

From the people in `ENVIRONMENT.md`, one errand each, in the protocol's shape:
who they are, the situation, what they came to get done, and where they start.

Three things make an errand work:

- **Something to finish**, not something to review. "Have a look at the
  catalogue" produces opinions; "the bike you took in yesterday needs to be up
  for sale by tonight" produces stumbling.
- **A reason to be there** that explains what they'd care about — somebody in
  a hurry, somebody checking on their phone, somebody who has never seen this.
- **No hints.** Don't name the screen, the button or the order to do things
  in. Every hint you give is a hesitation you'll never hear about.

Vary the device where the person implies it: whoever checks something at night
is on a phone, and the run says so.

## 2. Send them, one at a time

One `scout` per errand, **serially**, each with its errand, its starting
address, the naming prefix for anything it creates, and nothing else. No
protocol, no register, no map — it can't read files anyway, and everything you
add to the prompt is something it "knows" that a person arriving wouldn't.

Serial is not a limitation to work around: two scouts on the same store at
once change each other's screens, and what comes back is invented friction.

Between scouts, say in one line whether the errand got done. If one comes back
saying its screenshots were empty, **stop the run** — everything downstream
would be built on an agent guessing at what it saw.

## 3. Verify

One `scout-lead` with the report path and every diary. It goes and checks what
they couldn't find, measures why it was missable, kills the suggestions that
already exist or that contradict a written decision, and writes
`docs/scout/REPORT-NNN-<module>.md` plus the rows in `docs/scout/REGISTER.md`.

## 4. Hand it back

Short, and useful without opening a file:

- Which errands got finished, and which didn't.
- The worst friction in one sentence, with its id.
- What turned out to be there all along, and what genuinely wasn't — the
  difference decides whether the fix is a new feature or a label.
- Anything that looked like a plain defect rather than friction, said clearly,
  and that the user decides where it goes.
- That nothing has been built, and accepting a suggestion is their call.

## What this skill does NOT do

- **It doesn't build anything**, and it doesn't hand suggestions to whoever
  builds. That decision is the user's.
- **It doesn't bring services up**, and it doesn't sign in.
- **It doesn't run scouts in parallel** to save time.
- **It doesn't coach the scouts.** A scout told where to click is a scout
  whose report is worthless.
