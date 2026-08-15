---
name: cazabugs-init
description: Prepares this project for the bug agent chain — creates docs/bugs/ with the protocol, the queue and an ENVIRONMENT.md filled in from how the project actually runs. Use when the user invokes /cazabugs-init, when they ask to install or set up cazabugs, or when a bug agent stops because docs/bugs/ENVIRONMENT.md is missing.
---

# Skill: cazabugs-init

You leave this project ready for the `bug-reporter → bug-detective →
bug-hunter → bug-auditor` chain. Runs **once per project**, and again whenever
the environment changes.

The real work isn't copying three files: it's **filling in `ENVIRONMENT.md`**.
That file is what lets an agent verify in the right direction instead of
spending half an hour probing made-up addresses — a cost this chain already
paid once and shouldn't pay again.

## Step 1: check whether it's already there

If `docs/bugs/PROTOCOL.md` exists, **don't stomp on it**. It may carry the
user's adjustments, with live dossiers sitting next to it. Say what's already
there and offer:

- filling in or fixing only `ENVIRONMENT.md` (the usual case), or
- reinstalling everything, warning that local adjustments are lost.

## Step 2: copy the protocol and the queue

From `templates/` (next to this file) into `docs/bugs/`:

- `PROTOCOL.md` — the priority scale, the states, and the dossier template.
  Goes in as-is: it's the method, and it doesn't depend on the project.
- `QUEUE.md` — the empty index.

If the project keeps its documentation elsewhere, ask where and use that
folder; then say so, because the agents look in `docs/bugs/`.

## Step 3: find out how the project runs

This is the part that matters. **Investigate first, ask second**: showing up
with three things figured out and one concrete doubt beats a questionnaire.

Look at whatever's there: `README.md`, `CLAUDE.md`, `package.json` (or the
equivalent task file), `docker-compose.yml`, `Makefile`, `.env.example`,
`.claude/launch.json`, and the startup scripts.

What you have to leave answered:

1. **What addresses it runs at.** Ports included. If there are several pieces
   (site, panel, API), all of them.
2. **What command assembles the environment, and whether it's usable by an
   agent.** It almost never is: the ones that start everything tend to stay in
   the foreground —they hang the turn— and grab the ports the user already has
   open. Name them under "what must NOT be run", with the reason.
3. **How to get real data** for detail screens. Check whether the listing is
   rendered client-side: if so, the served HTML carries not a single link and
   you have to go to the API or the database. Leave the exact command, tested.
4. **What checks exist**: types, linter, tests. With their command. And which
   ones NOT to run (a build that stomps on the dev server's folder, a
   ten-minute suite).
5. **The gotchas.** What trips up whoever arrives new. Truly hunt for them: an
   IP or host in the config that looks like the site's and is the API's; an
   unversioned env file worth something different on every machine; a server
   that takes so long to compile it looks like it's down.

**Verify what you write.** An address that doesn't answer, a command that
doesn't exist, or a made-up identifier in `ENVIRONMENT.md` is worse than
leaving the blank: the agent will take it as true. If you couldn't verify
something, write it down as pending and say so.

Ask the user only what you can't verify yourself: which services they bring
up, which ones are theirs and must not be touched, and whether anything breaks
easily.

## Step 4: the probe, if it's worth it

If the project has several pieces or data that must come out of an API, write
a short script that answers the **whole** ENVIRONMENT at once —what's up,
routes, one real identifier— and record it under the "Probe" section.

It's the biggest saver there is: an agent pays its whole context on every
turn, so ten loose questions cost ten times what one probe that answers them
together does. Three details learned the hard way:

- Tell **down** apart from **up but compiling**. With `curl`, exit code 7
  means nobody's there and 28 means somebody's there but busy. Confusing them
  makes an agent stack an environment on top of the one already running.
- Don't assume the machine: no absolute paths, no values pulled from files
  that aren't versioned. Derive the root from the script's own location.
- `ss` and `lsof` don't exist everywhere; `curl` does.

## Step 5: tell the user how it's used

Short, and with their part in it:

- How a bug comes in: they tell Claude, who hands it to the `bug-reporter`.
- That the chain is chained by the main session and can pause between steps.
- That the `bug-hunter` **does not commit**: the fix stays in the working
  tree for the auditor to test, and the commit is the user's call.
- That the environment is theirs to bring up, because the agents don't.
- And what was left half-done in `ENVIRONMENT.md`, if anything was.

## What you do NOT do

- **You don't fix bugs and you don't register any.** This only lays the
  ground.
- **Don't invent the contents of `ENVIRONMENT.md`.** A wrong map is worse
  than none: it sends the agent, fully confident, to a place that doesn't
  exist.
- Don't change `PROTOCOL.md`. If this project needs a different rule, it goes
  in `ENVIRONMENT.md`.
- Don't install dependencies or bring up services to find things out.
