---
name: forja-init
description: Prepares this project for the feature agent chain — creates docs/features/ with the protocol and the board, and leaves ENVIRONMENT.md settled, reusing whatever already exists. Use when the user invokes /forja-init, when they ask to install or configure forja, or when a feature agent stops because ENVIRONMENT.md is missing.
---

# Skill: forja-init

You leave this project ready for the `feature-analyst → feature-architect →
feature-builder → feature-reviewer` chain. It runs **once per project**, and
again when the environment changes.

The real work isn't copying two files: it's **leaving `ENVIRONMENT.md`
settled**. That file is what makes an agent verify in the right direction
instead of spending half an hour trying invented ones.

## Step 1: check whether it's already there

If `docs/features/PROTOCOL.md` exists, **don't stomp on it**. It may carry the
user's adjustments, with live dossiers sitting next to it. Say what's already
there and offer: fix only `ENVIRONMENT.md`, or reinstall everything with a
warning that the local adjustments are lost.

## Step 2: ENVIRONMENT.md — before anything else, look for it

**This is the step where things break if you rush.** In order:

1. **Does `docs/bugs/ENVIRONMENT.md` exist?** Then this project already runs
   the bugs chain and that file **is in use**. Don't copy it, don't move it,
   and **don't modify it**: the bug agents read it as-is. The feature agents
   find it on their own — their protocol tells them to look there when there
   isn't one in `docs/features/`.

   Read it and check it's still true. If it's missing something features need
   and bugs don't — the list of areas, the live patterns — **tell the user
   and let them decide** whether to extend it. You don't touch it.

2. **Does `docs/features/ENVIRONMENT.md` exist?** Fix it if needed.

3. **Neither exists?** Create it at `docs/features/ENVIRONMENT.md` from
   `templates/`, and go on to step 4 to fill it.

If you end up finding **both**, say so: one has to be deleted. Two maps drift
apart, and the wrong one sends someone to a place that doesn't exist.

## Step 3: copy the protocol and the board

From `templates/` (next to this file) to `docs/features/`:

- `PROTOCOL.md` — the states, the dossier template, the slice rule and the
  turn budgets. Goes as-is: it's the method.
- `BOARD.md` — the empty index.

If the project keeps its documentation elsewhere, ask where and use that
folder; then say so, because the agents look in `docs/features/`.

## Step 4: find out how the project runs

Only if you had to create a new `ENVIRONMENT.md`. **Investigate first, ask
after**: showing up with three things figured out and one concrete question is
worth more than a questionnaire.

Look at, depending on what's there: `README.md`, `CLAUDE.md`, `package.json`
(or the equivalent task file), `docker-compose.yml`, `Makefile`,
`.env.example`, `.claude/launch.json`, and the startup scripts.

What you have to leave answered:

1. **What addresses it runs on.** Ports included, every piece.
2. **What command mounts the environment, and whether an agent can use it.**
   It almost never can: the ones that start everything tend to stay in the
   foreground — they hang the turn — and take the ports the user already has
   open. Name them under "what must NOT be run", with the reason.
3. **How to get real data** for detail screens. Check whether the listing
   renders client-side: if it does, the served HTML carries not a single
   link. Leave the exact command, tested.
4. **The areas** — this repository's packages or layers. It's the `area:`
   field of every dossier; without the list, every agent invents its own.
5. **What checks exist**: types, linter, tests, with their command. And which
   ones NOT to run.
6. **The live patterns**, if they're already known: the reference listing,
   the reference form. This is specific to features, and it saves the
   architect half of its exploration.
7. **Whether there's a project graph.** Check whether
   `graphify-out/graph.json` exists and whether the post-commit hook is
   installed (`graphify hook status`). The architect and the reviewer consult
   it before searching by hand. Note it exactly as it is: saying there's a
   graph when there isn't sends an agent off to run a command that fails.
   **Don't build it yourself** — that's the user's decision, and on this
   repository it may be expensive.

8. **The gotchas.** Actually hunt for them: an IP or a host in the config
   that looks like the site's and is the API's; an unversioned environment
   file that differs on every machine; a server that takes so long to compile
   it looks like it's off.

**Check what you write.** An address that doesn't respond or an invented
identifier is worse than leaving the blank: the agent will take it as good.
If you couldn't verify something, write it down as pending and say so.

Ask the user only what you can't verify yourself: which services they bring
up, which ones are theirs and must not be touched, and whether something
breaks easily.

## Step 5: the probe, if it's worth it

If the project has several pieces, or data that has to come out of an API,
write a short script that answers **the whole** environment at once and note
it in the "Probe" section. Three details learned the hard way:

- Tell **down** apart from **up but compiling**. With `curl`, exit code 7
  means nobody's there and 28 means someone's there but busy. Confusing them
  makes an agent mount an environment on top of the one already running.
- Don't take the machine for granted: no absolute paths, no values pulled
  from files that aren't versioned. Let the root come out of the script
  itself.
- `ss` and `lsof` don't exist everywhere; `curl` does.

**If the bugs chain already has a probe, reuse it.** Don't write a second one
that does the same thing.

## Step 6: tell the user how it's used

Short, and with what falls to them:

- How a feature comes in: they tell it to Claude, who hands it to the
  `feature-analyst`.
- That **the architect doesn't always come in** — only when the feature
  introduces a new concept — and that decision gets written down with its
  reason.
- That the main session is what chains the chain, and **it can stop between
  steps**: state lives on disk, so the analyst can run today and the builder
  tomorrow.
- That building happens **by slices**, and each one gets reviewed before the
  next.
- That the `feature-builder` **does not commit**: the change stays in the
  working tree for the reviewer to try, and the commit is the user's call.
- That they mount the environment, because the agents don't.
- And what was left half-done in `ENVIRONMENT.md`, if anything.

## What you do NOT do

- **You don't modify `docs/bugs/`.** Not the `ENVIRONMENT.md`, not the
  protocol, not the queue. If the bugs chain runs in this project, it has to
  keep running exactly the same after you've been through here.
- **You don't create features or build them.** This only prepares the ground.
- **You don't invent the content of `ENVIRONMENT.md`.** A wrong map is worse
  than none: it sends the agent to a place that doesn't exist, with full
  confidence.
- Don't change `PROTOCOL.md`. If this project needs a different rule, it goes
  in `ENVIRONMENT.md`.
- Don't install dependencies or bring up services to find things out.
