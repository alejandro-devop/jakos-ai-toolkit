# Testing protocol

How this project's QA squad works: what a session is, what counts as a
finding, and what separates a defect from a decision. The addresses, the real
data and the gotchas of **this** repository live in
[ENVIRONMENT.md](ENVIRONMENT.md), not here.

Three agents, and none of them does the other's job:

```
qa-planner  →  qa-tester (one per charter)  →  qa-triage
 finds the      executes, measures and         removes duplicates, separates
 oracles and    documents                      defect from decision, registers
 writes the
 charters
```

Whoever plans does not judge whether the session found anything worth having,
and whoever tests does not decide what enters the register. That separation is
the whole reason there are three.

## Where things live

- `docs/qa/REGISTER.md` — the index. One row per finding that made it in.
- `docs/qa/SESSION-NNN-<module>.md` — the session: its oracles, its charters
  and every entry, including the ones that did not make it into the register.
- `docs/qa/ENVIRONMENT.md` — how to run and check things in this project.

`NNN` is sequential, three digits, taken by listing the folder **right before
writing**: more than one session can share a working tree. Finding ids are
`F-001` and up, and they never get reused, not even after a discard.

## The oracle, which comes before everything

An oracle is whatever states what **correct** means. Without one there is no
finding, only an opinion, and an opinion turns into an argument about whether
it was a bug at all.

Where they usually live: the validation schemas (the densest one — every
field's real limits), the layer that writes to storage, the standing decisions
written in prose (`CLAUDE.md`, pattern and planning documents), and the tests
that already pass.

**The most valuable oracle is the one that says something is deliberate.** It
is what stops a decision from being reported as a defect, over and over, by
every new pair of eyes.

When no oracle exists, that is not a gap to fill by guessing: it is a
**question**, and it gets registered as one.

## Kinds of finding

| Kind | Rule | Where it can go |
|---|---|---|
| **bug** | Contradicts an oracle, which is cited | Can be dispatched to a bug chain |
| **improvement** | Works as specified and still gets in the way | Stays in the register |
| **question** | No rule exists either way | Stays until somebody answers it |

An answered question is a business rule that was never written down. Writing
the answer into the project's documentation is what makes the next session
sharper — and it is the cheapest documentation anybody will ever write,
because the question already found the gap.

## Severity, and why it is not priority

Severity is **damage**, and it is all this squad measures:

| | |
|---|---|
| **S1** | What someone typed is lost, or the task cannot be completed at all |
| **S2** | Wrong result or wrong state, with a way around it |
| **S3** | Visible defect that does not change the outcome: wrong label, misalignment, inconsistent wording |

Priority — how urgent this is for the business — is decided by whoever
receives the finding. Two scales for the same defect means two numbers that
disagree, and then neither is trusted.

**Frequency goes next to severity, always**: `always`, or `3 of 5` with the
attempts written down. Intermittent is a different animal from constant, and
the difference decides whether anybody else can even reproduce it.

## States

| State | Means |
|---|---|
| `new` | In the register, nobody has taken it |
| `dispatched` | Handed to a chain that fixes it; the row carries the id it got there |
| `discarded` | Not a defect, or not worth acting on. **Always with a reason** |
| `answered` | A question somebody answered; the answer is written down |
| `incomplete` | Did not make it into the register: it does not stand on its own. Stays in the session file with what it lacks |

A discard with no reason is how a real defect gets buried. If it was discarded
because an oracle allows it, the line that allows it goes in the row.

## The charter

One mission per tester, small enough to finish and big enough to matter:

```
Explore <area>
with <techniques>
to discover <what information>
```

It carries its area (and what is out of it), the techniques that apply, the
oracles with paths and lines — or *no oracle, questions expected* — and the
prefix for any data it creates.

Between three and six per session. Fewer leaves the module unexplored; more
makes triage the bottleneck.

## Techniques

Boundary values, equivalence classes, decision tables, state transitions,
round trip (what was saved is what is read back), interruption (escape,
reload, back, two tabs, double save) and, last, error guessing. Naming which
one a charter uses is not bureaucracy: it is what makes a session repeatable
and what tells anyone reading the file where it did **not** look.

## Entry template

```markdown
### F-000 — <one line, what happens, not what you think causes it>

- **Kind:** bug | improvement | question
- **Severity:** S1 | S2 | S3   **Frequency:** always | N of M
- **Charter:** C0
- **Where:** <screen, route or area>

**Steps**
1.
2.

**Expected:** <and the oracle: path, line, the sentence>
**Actual:** <what happened, measured, not described>
**Evidence:** <the literal output: computed value, request status, console line>
**Suspicion:** <optional, one line, labelled as such>
```

The suspicion is optional and stays one line on purpose. Whoever investigates
later has to be able to reach a different conclusion without fighting yours.

## Running the session

**Serial by default.** Testers write data, and two of them writing at once
over the same store contaminate each other's readings: a list that changes
under you, a record somebody else archived. That does not produce a missed
bug — it produces an invented one, which is worse.

Charters that only read may run at the same time, and the planner says which
ones those are.

## How not to overspend

An agent pays its whole context on every turn, so what costs is not thinking:
it is how many times it stops to ask for something and how much it drags
along.

- **One probe that measures six things costs the same as one that measures
  one.** Before running a measurement, ask what else you will want to know
  when you see the result, and measure it now.
- **Read only your part.** The tester reads its charter, not the others'. The
  triage reads the entries, not the code the tester walked through.
- **Cap what you dump from the browser.** A full page dump sits in your
  context until the end of the task.
- **Reduce before writing.** Nine steps become four, and two findings turn out
  to be one.
