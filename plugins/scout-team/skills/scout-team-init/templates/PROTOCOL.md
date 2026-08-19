# Scouting protocol

How this project's scout team works: what an errand is, what counts as
friction, and what turns friction into a suggestion worth acting on. The
addresses, the people who really use this and the gotchas of **this**
repository live in [ENVIRONMENT.md](ENVIRONMENT.md).

Two agents, and the split between them is the entire method:

```
scout (one per errand)  →  scout-lead
 eyes and hands only,       verifies, measures, and turns
 no page structure,         friction into suggestions
 no source
```

## Why the scout is deprived of tools

An agent that reads a page's structure receives a perfect tree where every
control is labelled and even what is hidden is listed. It never fails to find
anything, because the tree hands it over. Which means it can never report the
one thing this team exists to report: **that a person would not have found
it.**

So the scout doesn't have those tools. Not "shouldn't use them" — doesn't
have them. A rule enforced by capability is the only kind that holds when the
work gets tedious.

The verification comes right after, from the lead, and it is stronger for
having been split in two: the scout says *"I never found it"*, the lead says
*"it was there, at 2.4:1, behind a menu with no label"*. One of those is a
feeling. Together they are evidence.

## Where things live

- `docs/scout/REGISTER.md` — the index. One row per suggestion.
- `docs/scout/REPORT-NNN-<module>.md` — the run: its errands, the diaries as
  the scouts wrote them, the verifications and the suggestions.
- `docs/scout/ENVIRONMENT.md` — addresses, who really uses this, and what may
  be touched.

`NNN` is sequential, three digits, taken by listing the folder right before
writing. Suggestion ids are `S-001` and up and never get reused.

## The errand

A scout is not sent to "review the module". It is sent to **get something
done**, as somebody in particular, and its report is where that went wrong:

```
You are <who>. <The situation, in one or two lines.>
<What you came to get done.>
Start at <address>.
```

The people are not invented per run: they are the ones written down in
`ENVIRONMENT.md`, because who really uses this belongs to the project. Three
errands is the usual size — the same module, three different reasons to be
there.

**Errands run one at a time.** Scouts write data, and two of them working the
same store at once contaminate each other's readings: a list that shifts
underneath, a record somebody else archived. That doesn't lose a finding, it
invents one.

## Friction, and how it is measured

Friction is anything that made the person work harder than the task required:
hesitating, hunting, guessing, backtracking, being afraid to click, acting
twice because nothing confirmed the first time, or never finding it at all.

Each one carries **cost** and **how often it is paid**, and the two always
travel together:

| Cost | |
|---|---|
| **F1** | Stopped them: they couldn't finish, or finished wrong without noticing |
| **F2** | Made them guess: they got through it, unsure whether it was right |
| **F3** | Made them work extra: more clicks, more screens, more backtracking than needed |

| How often | |
|---|---|
| **Constant** | Every time anyone does this task |
| **Occasional** | Only on a path some people take |
| **First time only** | Costs once per person and never again |

Neither number decides alone. Something that stops one person once a year and
something that costs three extra clicks forty times a day are not the same,
and which is worse is a judgement — so both numbers go in the row and the
judgement stays with whoever reads it.

**First time only** is not a synonym for unimportant: it is what everybody
pays before they can pay anything else.

## Suggestion template

```markdown
### S-000 — <what should change, in one line>

- **Cost:** F1 | F2 | F3   **How often:** constant | occasional | first time only
- **Friction it comes from:** <the scout's own words, quoted>
- **Verified:** <what the lead measured: it was there / it wasn't / at this
  size, this contrast, below the fold, hover only, labelled but not visible>
- **Suggestion:** <the change. If something needs saying, the exact words>
- **Roughly what it costs:** <one place or many; whether it needs a decision first>
```

Two rules the template can't enforce:

- **No friction, no suggestion.** Anything that didn't come from somebody
  stumbling is advice, and advice could have been written without opening the
  product.
- **Words, not intentions.** Where a message is missing, the suggestion
  carries the sentence itself, in the product's voice, saying what happened
  and what to do. A suggestion nobody can paste in is one nobody will act on.

## States

| State | Means |
|---|---|
| `new` | In the register, nobody has decided |
| `accepted` | The user wants it. Whoever builds it takes it from here |
| `rejected` | Not going to happen. **Always with a reason** |
| `already exists` | It was already built; the run found it, the report keeps it |

A rejection with no reason comes back next run, found again by somebody else,
and costs the same all over again.

## What this team never does

It doesn't fix, it doesn't build, and it doesn't file bugs in anybody's queue.
If a scout hits something plainly broken, it goes in the report marked as a
defect and the user decides where it goes. Deciding that on their behalf is
how one team's leftovers end up as another team's backlog.
