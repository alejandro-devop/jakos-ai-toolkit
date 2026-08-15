#!/usr/bin/env python3
"""Leak linter for the toolkit.

The chains keep evolving inside real projects, and improvements are ported
back here by hand. This catches the two things that sneak in when that
happens:

1. Host-project residue — ports, package managers, hostnames, script paths
   that only exist in the repository where the improvement was born. An agent
   with a wrong map walks confidently into a place that does not exist, and
   that does more damage than having no map.
2. Spanish leftovers — the toolkit's canonical language is English (dossiers,
   protocols, agent prose); anything the translation missed shows up here.

Usage:  python3 check.py        (from the repo root; exit 1 if anything is flagged)
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).parent
PLUGINS = ROOT / "plugins"

# Things that only make sense in a specific host project.
HOST_RESIDUE = re.compile(
    r"moto-hertz|localhost:\d|:300[0-9]|:8080|192\.168|cms-admin|pnpm |"
    r"next build|next dev|npx tsc|entorno-bugs|"
    r"\.claude/(agents|skills|issues|entorno)"  # origin-repo layout; plugin files live next to their skill
)

# Accented characters catch nearly all Spanish prose; the word list catches
# the un-accented vocabulary this toolkit used before the translation.
SPANISH = re.compile(
    r"[áéíóúñ¿¡]|\b(expediente|rebanada|sonda|cola|tablero|entorno|"
    r"arreglo|plantilla|adjuntos|cerco|sello|turnos)\b",
    re.IGNORECASE,
)

def main() -> int:
    targets = sorted(
        p for suffix in ("*.md", "*.sh", "*.mjs", "*.json")
        for p in PLUGINS.rglob(suffix)
    )
    if not targets:
        print("Nothing under plugins/ — wrong directory?")
        return 1

    flagged = 0
    for f in targets:
        for n, line in enumerate(f.read_text().splitlines(), 1):
            hits = []
            if HOST_RESIDUE.search(line):
                hits.append("host-residue")
            if SPANISH.search(line):
                hits.append("spanish")
            if hits:
                print(f"  {f.relative_to(ROOT)}:{n}  [{','.join(hits)}]  {line.strip()[:80]}")
                flagged += 1

    print("clean" if not flagged else f"\n{flagged} line(s) to review by hand")
    return 1 if flagged else 0

if __name__ == "__main__":
    sys.exit(main())
