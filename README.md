# jakos-ai-toolkit

Agents and skills for Claude Code that travel from project to project. They
come out of real work and are detached from the repository where they were
born: whatever belongs to the project stays out, in a file each project
generates for itself.

## What's inside

### cazabugs

Four agents that pass a bug from hand to hand, and **none of them trusts the
previous one**:

```
bug-reporter  →  bug-detective  →  bug-hunter  →  bug-auditor
 records and      reproduces and     fixes,        tries to knock the fix
 prioritizes      finds the cause    doesn't close  down through another path
```

Three separations hold up everything else:

- **The detective doesn't fix**, not even an obvious line. If it fixes, nobody
  looks at that code with fresh eyes.
- **The hunter doesn't close**, and leaves the fix uncommitted so it gets
  audited exactly as it is. Nobody audits themselves.
- **The auditor doesn't touch code.** The moment it fixes what it found, it
  stops looking from the outside. What it finds, it returns.

What they pass around is not conversation context: it is a dossier in
`docs/bugs/`, with four sections, that survives closing the session. Priority
is decided with a single question — *can the person finish what they came to
do?* — and not by technical severity, which over time turns everything urgent.

Includes `/bugs-github`, which brings the issues labeled `bug` into the queue
and, on close, replies on the issue in the language of whoever reported it.

### forja

The sibling of `cazabugs` for the other side of the work: building something
that doesn't exist yet.

```
feature-analyst  →  feature-architect  →  feature-builder  →  feature-reviewer
 problem, limits     what exists already    one slice,          criteria, and what
 and criteria        and where new code     uncommitted         broke next door
                     goes
```

The same separations — whoever plans doesn't build, whoever builds doesn't
close, whoever reviews doesn't touch code — plus two things that only make
sense for features:

- **The architect doesn't always run.** One question decides it: *does this
  introduce a new concept, or does it hang off one that already exists?* What
  hangs off goes straight to the builder. The decision is written down **with
  its reason**, because getting it wrong the other way means building for the
  second time something that was already there — and that isn't discovered
  until months later.
- **Work happens in vertical slices**, each reviewed before the next. The
  analyst and the architect run once per feature; the builder and the reviewer
  loop once per slice.

Acceptance criteria are written **before** building and nobody rewrites them
afterwards: the reviewer reads them literally, not the version the builder
remembers. And every agent carries a turn budget whose purpose is not to cut
its work short, but to make it **stop and ask instead of insisting** — which
is where the spend goes.

If the project has a [graphify](https://github.com/Graphify-Labs/graphify)
graph (`graphify-out/`), the architect and the reviewer consult it before
searching by hand: "what's around this?" and "who else uses this?" are one
call instead of many rounds of grep. It's optional — with no graph, the agents
search by hand, and nobody builds one on their own.

### qa-squad

Where `cazabugs` waits for a bug to be reported, this one goes looking. Three
agents, and the split is the point:

```
qa-planner  →  qa-tester (one per charter)  →  qa-triage
 finds the      executes, measures and         removes duplicates, separates
 oracles and    documents                      defect from decision, registers
 writes the
 charters
```

**It hunts the way a QA does, not by wandering.** Before anything is tried,
the planner finds the *oracles* — whatever states what correct means here:
validation schemas, the layer that writes to storage, the documents carrying
standing decisions. Without an oracle there is no finding, only an opinion,
and every finding cites the one it was measured against. Testers apply named
techniques (boundary values, decision tables, state transitions, round trip,
interruption — and error guessing last, as one technique rather than the
method).

Three kinds come out, and only one of them is a bug: what contradicts an
oracle. What works as specified and still gets in the way is an
**improvement**; what no rule covers is a **question** — and every question
somebody answers is a business rule the project never wrote down.

Findings live in the squad's own register. `/qa-dispatch` is what hands one to
`cazabugs`, and it is a separate command because it is the user's decision.

### scout-team

The other half of "is this any good": not *is it broken*, but *does it let you
use it*.

```
scout (one per errand)  →  scout-lead
 eyes and hands only,       verifies, measures, and turns
 no page structure,         friction into suggestions
 no source
```

**The scout is deprived of tools on purpose.** An agent that reads a page's
accessibility tree gets every control handed to it, labelled, including the
hidden ones — so it can never report the one thing this team exists for: that
a person would not have found it. So it doesn't have those tools. It looks,
it clicks, it types, and when it can't find something, that *is* the finding.

Then the lead goes and checks: was it there? At what size, at what contrast,
below the fold, behind a hover that doesn't exist on a phone, labelled for a
screen reader but invisible to an eye? The scout says *"I never found how to
remove it"*; the lead says *"it was there at 2.4:1 behind an unlabelled
menu"*. One is a feeling; together they are evidence.

Scouts are sent as the people who really use the product — written down once
per project, not invented per run — with an errand to finish rather than a
module to review. No friction, no suggestion: anything nobody stumbled over is
advice, and advice could have been written without opening the product. Where
something needs to be said, the suggestion carries the sentence itself, in the
product's voice.

## Installing into a project

```bash
claude plugin marketplace add alejandro-devop/jakos-ai-toolkit
claude plugin install cazabugs@jakos-ai-toolkit
claude plugin install forja@jakos-ai-toolkit
claude plugin install qa-squad@jakos-ai-toolkit
claude plugin install scout-team@jakos-ai-toolkit
```

They are independent: install one without the others. And inside the project,
once each:

```
/cazabugs-init
/forja-init
/qa-squad-init
/scout-team-init
```

That creates `docs/bugs/` and `docs/features/` with their protocol and their
index, and — the part that actually matters — an `ENVIRONMENT.md` with the
addresses where *that* project runs, how to get real data, and its own
gotchas. **Without that file the agents spend half an hour trying made-up
addresses**, which is the waste this step exists to cut.

**That map is a single one, and it's shared.** Whichever chain runs first
writes it; the rest find it and don't touch it — `/forja-init` detects the bug
chain's `ENVIRONMENT.md`, reuses it as-is and writes nothing into
`docs/bugs/`. The two newer ones each add a section of their own that nobody
else's map has: how the agents get past a sign-in and what test data they may
create, and — for the scouts — **who really uses this product**.

To try things out before publishing anything, the marketplace also accepts a
local path:

```bash
claude plugin marketplace add ~/Developer/jakos-ai-toolkit
```

## Updating

```bash
claude plugin marketplace update jakos-ai-toolkit
claude plugin install cazabugs@jakos-ai-toolkit
claude plugin install forja@jakos-ai-toolkit
claude plugin install qa-squad@jakos-ai-toolkit
claude plugin install scout-team@jakos-ai-toolkit
```

The `-init` skills don't stomp on what's already there: if they find a
`PROTOCOL.md`, they offer to touch only the `ENVIRONMENT.md`. The dossiers,
the queue and the board are yours and are never touched.

## Migrating projects that used the Spanish version (≤ 0.1.0)

Up to 0.1.0 the toolkit worked in Spanish; from 0.2.0 everything — agent
prose, protocols, dossiers, front-matter — is English. Projects initialized
with the Spanish version keep working if you pin the old plugin version, but
to move one over, rename the working files and update the shared vocabulary:

| Spanish (old) | English (new) |
|---|---|
| `docs/bugs/PROTOCOLO.md`, `COLA.md`, `ENTORNO.md` | `PROTOCOL.md`, `QUEUE.md`, `ENVIRONMENT.md` |
| `docs/features/PROTOCOLO.md`, `TABLERO.md` | `PROTOCOL.md`, `BOARD.md` |
| `docs/bugs/adjuntos/` | `docs/bugs/attachments/` |
| front-matter: `titulo`, `estado`, `prioridad`, `actualizado`, `reportado`/`pedido`, `arquitecto` | `title`, `status`, `priority`, `updated`, `reported`/`requested`, `architect` |
| bug states: `reportado`, `analizado`, `arreglado`, `devuelto`, `cerrado`, `no-reproducible`, `descartado` | `reported`, `analyzed`, `fixed`, `returned`, `closed`, `not-reproducible`, `discarded` |
| feature states: `pedido`, `especificado`, `planeado`, `en-construcción`, `en-revisión`, `entregado`, `bloqueado` | `requested`, `specified`, `planned`, `building`, `in-review`, `delivered`, `blocked` |
| agents: `feature-analista`, `feature-arquitecto`, `feature-constructor`, `feature-revisor` | `feature-analyst`, `feature-architect`, `feature-builder`, `feature-reviewer` |
| scripts: `issues-bug.sh --tope` / `issues-cerrar.sh --cerrar` | `issues-fetch.sh --limit` / `issues-close.sh --close` |

The simplest path: re-run `/cazabugs-init` / `/forja-init` (they will offer to
reinstall the protocol) and rename existing dossiers' front-matter by hand.
Old dossiers in Spanish stay readable either way — agents only need the shared
file names and states to match.

## How it's used, once installed

**A bug:**

1. You tell Claude about it, or run `/bugs-github`.
2. It goes to the `bug-reporter`, which records it and sets a priority.
3. You tell it to go on, and the main session chains detective → hunter →
   auditor. **You can stop between steps**: the state lives on disk.
4. The auditor closes and leaves you a summary of what was wrong and how it
   got fixed.
5. The commit is yours to make, with the bug already closed.

**A feature:**

1. You tell Claude, and Claude hands it to the `feature-analyst`.
2. It comes back with the scope, the criteria, the slices and — if there are
   any — the decisions that are yours to make. **That's where you answer**,
   and it's on purpose: a decision resolved now is worth half an hour of a
   blocked builder later.
3. If the feature introduces a new concept, the architect comes in and finds
   out what already exists. If it hangs off something that's already there, it
   gets skipped.
4. Builder and reviewer loop per slice. Every loop leaves you something
   usable.
5. The commit is yours.

**A QA session:**

1. `/qa-run <module>`. The planner writes the charters, the testers run them
   **one at a time** — they write data, and two at once invent findings that
   were never there — and the triage registers what survived.
2. You get back the count by kind, the worst one, and **the questions**: the
   things only you can settle. Each answer is a rule the project never wrote
   down, and writing it down makes the next session sharper.
3. `/qa-dispatch <ID>` sends a bug to `cazabugs`. Nothing leaves the register
   on its own.

**A scouting run:**

1. `/scout-run <module>`. If there's a sign-in, you open it first — agents
   never type credentials.
2. The scouts go one at a time, each as one of the people who really use the
   product, each with something to finish. Then the lead verifies what they
   couldn't find and measures why.
3. You get suggestions, each tied to somebody actually stumbling, with the
   wording where wording is what's missing. Accepting one is your call.

**You bring up the environment.** The agents don't start or stop services: if
something is down they say so and continue with whatever doesn't depend on it.

## Maintaining this

The toolkit is the canonical home of both chains, in English. They still
improve inside real projects; those improvements are ported back here by hand.
After porting anything, run

```bash
python3 check.py
```

which flags host-project residue (ports, package managers, script paths from
the repository where the improvement was born) and any Spanish leftovers. What
it flags, you review by hand: **an agent with a wrong map walks confidently
into a place that does not exist**, and that does more damage than having no
map.
