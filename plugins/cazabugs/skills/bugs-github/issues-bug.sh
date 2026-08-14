#!/usr/bin/env bash
# Sonda de issues con label 'bug' para la skill /bugs-github.
#
# Trae de una sola vez lo que hace falta para registrar un bug reportado en
# GitHub: los issues abiertos con label 'bug' que TODAVÍA NO están en
# docs/bugs/, su cuerpo, sus comentarios y sus capturas ya bajadas a disco.
#
# El filtro de "todavía no" es lo importante: sin él, correr la skill dos veces
# crea dos expedientes del mismo bug. Se hace mirando el campo `github_issue:`
# del front-matter de los expedientes, que es el único sitio donde ese vínculo
# sobrevive entre sesiones.
#
# Uso:
#   issues-bug.sh              # los pendientes, hasta 5
#   issues-bug.sh --tope 10    # sube el tope del lote
#   issues-bug.sh --issue 12   # solo ese, aunque ya esté registrado
#
# Esta sonda NO escribe expedientes ni toca la cola: solo lee GitHub y baja
# archivos a docs/bugs/adjuntos/. Registrar es trabajo del bug-reporter.

set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ" || exit 1

TOPE=5              # issues por corrida — cada uno cuesta un subagente entero
CAPTURAS=2          # capturas por issue — cada imagen leída se paga en contexto
SOLO=""

while [ $# -gt 0 ]; do
  case "$1" in
    --tope)  TOPE="${2:-5}";  shift 2 ;;
    --issue) SOLO="${2:-}";   shift 2 ;;
    *) echo "argumento que no conozco: $1" >&2; exit 2 ;;
  esac
done

command -v gh >/dev/null || { echo "ERROR: no está el CLI 'gh'."; exit 1; }
gh auth status >/dev/null 2>&1 || {
  echo "ERROR: 'gh' no está autenticado. El usuario tiene que correr 'gh auth login'."
  exit 1
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Una sola llamada a la API con todo lo que se va a querer saber después:
# cuerpo, autor, fecha y comentarios. Los comentarios importan porque es donde
# suele aparecer la captura que faltaba en el cuerpo.
if ! gh issue list --label bug --state open --limit 100 \
       --json number,title,body,author,createdAt,url,comments \
       > "$TMP/issues.json" 2>"$TMP/err"; then
  echo "ERROR consultando GitHub:"; cat "$TMP/err"; exit 1
fi

# Los que ya tienen expediente. Sale del front-matter, no de una lista aparte:
# una lista aparte se desincroniza, el front-matter no puede.
REGISTRADOS="$(grep -hoE '^github_issue: *[0-9]+' docs/bugs/*.md 2>/dev/null |
  grep -oE '[0-9]+' | sort -un | paste -sd, -)"

GH_TOKEN_SONDA="$(gh auth token 2>/dev/null)" \
node "$RAIZ/.claude/issues-bug.mjs" \
  "$TMP/issues.json" "${REGISTRADOS:-}" "$TOPE" "$CAPTURAS" "$SOLO"
