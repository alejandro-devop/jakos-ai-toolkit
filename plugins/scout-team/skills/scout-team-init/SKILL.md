---
name: scout-team-init
description: Prepares this project for the scout team — creates docs/scout/ with the scouting protocol, the suggestions register and an ENVIRONMENT.md that says where the product runs and, above all, who really uses it. Use when the user invokes /scout-team-init, when they ask to install or set up the scout team, or when a scouting agent stops because docs/scout/ENVIRONMENT.md is missing.
---

# Skill: scout-team-init

You leave this project ready for a `scout → scout-lead` run. Runs **once per
project**, and again whenever the environment or the people change.

Copying two files is the easy part. The work is **who really uses this**,
because that is what the errands are built from, and errands built from an
invented user produce three variations of the same generic complaint.

## Step 1: check whether it's already there

If `docs/scout/PROTOCOL.md` exists, **don't stomp on it** — it may carry the
user's adjustments with real reports next to it. Say what's there and offer
either filling in only `ENVIRONMENT.md` or reinstalling everything, warning
that local adjustments are lost.

## Step 2: copy the protocol and the register

From `templates/` into `docs/scout/`: `PROTOCOL.md` as-is, and `REGISTER.md`
empty. If the project keeps documentation elsewhere, ask and say so — the
agents look in `docs/scout/`.

## Step 3: reuse the map if one already exists

If another chain in this project already has an `ENVIRONMENT.md`, read it and
reuse what it answers: addresses, what must not be run, gotchas. Copy those
into `docs/scout/ENVIRONMENT.md` and write nothing into the other chain's
folder.

## Step 4: find out who uses this

The part nobody else's map has. Look in the product's own documentation, in
its planning documents, in the language of the interface itself — a product
usually says who it is for without meaning to. Then **ask the user**, because
this is the one thing they know and the repository doesn't.

For each one: what they come to do, how often they're here, on what device,
and how much they already know. Two or three is plenty.

**At least one should be arriving for the first time.** What a product assumes
you already know is invisible to everybody who already knows it — including,
especially, whoever built it.

## Step 5: the practical limits

- **Which browser.** There may be two: the app's own, and the person's
  browser through its extension. Name one. Two things decide it: where the
  person is already signed in, and whether screenshots come back — a hidden
  pane composites no frames and returns empty ones.
- **Sign-in.** Nobody installs a session, not the agents and not the run. The
  person signs in once beforehand in that browser and the scouts inherit it.
  Say how long it lasts and how an agent can tell it expired. If there's no
  way in, say so plainly: this team then cannot reach that part of the
  product.
- **What may be created and what may never be touched.** Scouts write while
  doing their errand.
- **Whether screenshots come back at all.** This matters more here than
  anywhere else: if the browser window can be hidden, they may come back
  empty, and a scout whose whole method is looking has to stop instead of
  carrying on from what it assumes. Find out and write down how to tell.

## Step 6: tell the user how it's used

- `/scout-run <module>` sends the scouts on their errands, **one at a time**,
  and the lead verifies and writes the report.
- The team **builds nothing**. What comes out is suggestions, each one tied to
  somebody actually stumbling.
- The environment is theirs to bring up, and if there's a sign-in, theirs to
  open before the run.
- What was left half-done in `ENVIRONMENT.md`, if anything was.

## What you do NOT do

- **You don't run a scouting pass and you don't register suggestions.**
- **Don't invent the people.** A made-up user produces made-up friction, and
  that is worse than no report at all: it looks exactly like the real thing.
- **Don't build a way past the sign-in.** If there is none, that's something
  to tell the user, not code for you to write.
- Don't change `PROTOCOL.md`. Project-specific rules go in `ENVIRONMENT.md`.
