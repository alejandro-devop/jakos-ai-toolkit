#!/usr/bin/env bash
# Probe for the /bugs-github skill: brings, in one go, everything needed to
# register a bug reported on GitHub — the open issues labeled 'bug' that are
# NOT yet in docs/bugs/, their body, their comments, and their screenshots
# already downloaded to disk.
#
# The "not yet" filter is the important part: without it, running the skill
# twice creates two dossiers for the same bug. It works by reading the
# `github_issue:` front-matter field of the dossiers, which is the only place
# where that link survives across sessions.
#
# Usage:
#   issues-fetch.sh              # pending issues, up to 5
#   issues-fetch.sh --limit 10   # raise the batch cap
#   issues-fetch.sh --issue 12   # just that one, even if already registered
#
# This probe does NOT write dossiers and does NOT touch the queue: it only
# reads GitHub and downloads files into docs/bugs/attachments/. Registering is
# the bug-reporter's job.

set -uo pipefail

# The probe acts on the project in the CURRENT working directory. The script
# itself lives inside the installed plugin — nowhere near the project — so the
# project root must come from where the caller stands, never from the script's
# own location.
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LIMIT=5             # issues per run — each one costs a whole subagent
SCREENSHOTS=2       # screenshots per issue — every image read is paid in context
ONLY=""

while [ $# -gt 0 ]; do
  case "$1" in
    --limit) LIMIT="${2:-5}"; shift 2 ;;
    --issue) ONLY="${2:-}";   shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

command -v gh >/dev/null || { echo "ERROR: the 'gh' CLI is not installed."; exit 1; }
gh auth status >/dev/null 2>&1 || {
  echo "ERROR: 'gh' is not authenticated. The user has to run 'gh auth login'."
  exit 1
}
command -v node >/dev/null || {
  echo "ERROR: 'node' (>= 18) is not available; the probe needs it to process the issues."
  exit 1
}
[ -d docs/bugs ] || {
  echo "ERROR: docs/bugs/ does not exist here ($ROOT). Run /cazabugs-init first."
  exit 1
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# One single API call with everything that will be wanted later: body, author,
# date and comments. Comments matter because that is where the screenshot that
# was missing from the body usually shows up.
if ! gh issue list --label bug --state open --limit 100 \
       --json number,title,body,author,createdAt,url,comments \
       > "$TMP/issues.json" 2>"$TMP/err"; then
  echo "ERROR querying GitHub:"; cat "$TMP/err"; exit 1
fi

# The ones that already have a dossier. It comes from the front-matter, not
# from a separate list: a separate list drifts out of sync, the front-matter
# cannot.
REGISTERED="$(grep -hoE '^github_issue: *[0-9]+' docs/bugs/*.md 2>/dev/null |
  grep -oE '[0-9]+' | sort -un | paste -sd, -)"

GH_TOKEN_PROBE="$(gh auth token 2>/dev/null)" \
node "$SCRIPT_DIR/issues-fetch.mjs" \
  "$TMP/issues.json" "${REGISTERED:-}" "$LIMIT" "$SCREENSHOTS" "$ONLY"
