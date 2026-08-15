#!/usr/bin/env bash
# Closes on GitHub the issues whose bug is already fixed AND published.
#
# It is the other half of issues-fetch.sh: that one brings issues into the
# queue, this one returns the result. The link between the two worlds is the
# same `github_issue:` front-matter field.
#
# The "published" rule trusts nobody: it looks at the dossier AS IT IS ON
# origin/main. If it says `status: closed` there, then the commit that left it
# that way is pushed, and since the fix and the dossier travel in the same
# commit, so is the code. A dossier closed only in the local tree does not
# count — that is exactly the mistake this exists to prevent: announcing
# "resolved" to the world with the fix living on one person's machine.
#
# Usage:
#   issues-close.sh            # says what it would close, touching nothing
#   issues-close.sh --close    # actually closes
#
# Dry-run by default on purpose: closing an issue is public and notifies
# whoever reported it. The detailed comment was left earlier by the
# bug-auditor; this only ties the bow.

set -uo pipefail

# Acts on the project in the CURRENT working directory — the script lives
# inside the installed plugin, nowhere near the project.
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1

CLOSE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --close) CLOSE=1; shift ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

command -v gh >/dev/null || { echo "ERROR: the 'gh' CLI is not installed."; exit 1; }
gh auth status >/dev/null 2>&1 || {
  echo "ERROR: 'gh' is not authenticated. The user has to run 'gh auth login'."
  exit 1
}

# Fresh origin/main. With no network we go on with whatever local reference
# there is: worse information, but never invented information — and the
# warning stays on record.
if ! git fetch --quiet origin main 2>/dev/null; then
  echo "WARNING: could not reach origin (no network?). Using the local reference of origin/main, which may be stale."
fi

echo "=== ISSUES TO CLOSE ==="
[ "$CLOSE" -eq 0 ] && echo "(dry-run: nothing gets closed; add --close to do it)"
echo

CLOSED=0; WAITING=0; ALREADY=0

for DOSSIER in docs/bugs/BUG-*.md; do
  [ -e "$DOSSIER" ] || continue

  NUM="$(grep -m1 -oE '^github_issue: *[0-9]+' "$DOSSIER" | grep -oE '[0-9]+')"
  [ -n "$NUM" ] || continue        # didn't come from GitHub: nothing to close

  # The status that counts is the published one, not the working tree's.
  PUBLISHED="$(git show "origin/main:$DOSSIER" 2>/dev/null |
    grep -m1 -oE '^status: *[a-z-]+' | awk '{print $2}')"
  LOCAL="$(grep -m1 -oE '^status: *[a-z-]+' "$DOSSIER" | awk '{print $2}')"

  if [ "$PUBLISHED" != "closed" ]; then
    if [ "$LOCAL" = "closed" ]; then
      echo "· #$NUM  $DOSSIER — closed locally but NOT PUSHED (on origin/main: ${PUBLISHED:-does not exist}). Left alone."
      WAITING=$((WAITING + 1))
    fi
    continue
  fi

  ISSUE_STATE="$(gh issue view "$NUM" --json state --jq .state 2>/dev/null)"
  if [ "$ISSUE_STATE" != "OPEN" ]; then
    ALREADY=$((ALREADY + 1))
    continue
  fi

  # The commit that left the dossier `closed` on origin/main is, in this
  # repo's flow, the same one that carries the fix.
  COMMIT="$(git log origin/main -1 --format='%h' -- "$DOSSIER")"
  ID="$(grep -m1 -oE '^id: *BUG-[0-9]+' "$DOSSIER" | awk '{print $2}')"

  if [ "$CLOSE" -eq 0 ]; then
    echo "· #$NUM  $ID  ($COMMIT)  — would be closed"
    CLOSED=$((CLOSED + 1))
    continue
  fi

  MESSAGE="Fixed and published on \`main\` (\`$COMMIT\`).

The detail of what was wrong, how it was fixed and what remains to be
confirmed is in the audit comment above. If something still fails, this gets
reopened: the dossier is \`$DOSSIER\`.

<!-- issues-close: $ID -->"

  if gh issue close "$NUM" --reason completed --comment "$MESSAGE" >/dev/null 2>&1; then
    echo "· #$NUM  $ID  ($COMMIT)  — closed"
    CLOSED=$((CLOSED + 1))
  else
    echo "· #$NUM  $ID  — ERROR closing (permissions? issue from another repo?). Stays open."
  fi
done

echo
echo "closed: $CLOSED | waiting for push: $WAITING | already closed: $ALREADY"
