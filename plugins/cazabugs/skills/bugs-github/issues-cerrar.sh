#!/usr/bin/env bash
# Cierra en GitHub los issues cuyo bug ya está arreglado Y publicado.
#
# Es la otra mitad de issues-bug.sh: aquella trae issues a la cola,
# esta devuelve el resultado. El vínculo entre los dos mundos es el mismo campo
# `github_issue:` del front-matter.
#
# La regla de "publicado" no se fía de nadie: mira el expediente TAL COMO ESTÁ
# EN origin/main. Si allí dice `estado: cerrado`, entonces el commit que lo dejó
# así ya está pusheado, y como el arreglo y el expediente van en el mismo commit,
# el código también. Un expediente cerrado solo en el árbol local no cuenta —
# ese es justo el error que esto evita: anunciarle al mundo "resuelto" con el
# arreglo viviendo en la máquina de uno.
#
# Uso:
#   issues-cerrar.sh            # dice qué cerraría, sin tocar nada
#   issues-cerrar.sh --cerrar   # los cierra de verdad
#
# El modo por defecto es en seco a propósito: cerrar un issue es público y le
# llega una notificación a quien lo reportó. El comentario con el detalle lo
# dejó antes el bug-auditor; este solo pone el lazo.

set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ" || exit 1

CERRAR=0
while [ $# -gt 0 ]; do
  case "$1" in
    --cerrar) CERRAR=1; shift ;;
    *) echo "argumento que no conozco: $1" >&2; exit 2 ;;
  esac
done

command -v gh >/dev/null || { echo "ERROR: no está el CLI 'gh'."; exit 1; }
gh auth status >/dev/null 2>&1 || {
  echo "ERROR: 'gh' no está autenticado. El usuario tiene que correr 'gh auth login'."
  exit 1
}

# origin/main fresco. Si no hay red se sigue con la referencia que haya en
# local: peor información, pero nunca información inventada — y el aviso queda.
if ! git fetch --quiet origin main 2>/dev/null; then
  echo "AVISO: no se pudo consultar origin (¿sin red?). Se usa la referencia local de origin/main, que puede estar vieja."
fi

echo "=== ISSUES A CERRAR ==="
[ "$CERRAR" -eq 0 ] && echo "(en seco: no se cierra nada; agrega --cerrar para hacerlo)"
echo

CERRADOS=0; PENDIENTES=0; YA=0

for EXP in docs/bugs/BUG-*.md; do
  [ -e "$EXP" ] || continue

  NUM="$(grep -m1 -oE '^github_issue: *[0-9]+' "$EXP" | grep -oE '[0-9]+')"
  [ -n "$NUM" ] || continue          # no vino de GitHub: no hay nada que cerrar

  # El estado que cuenta es el publicado, no el del árbol de trabajo.
  PUBLICADO="$(git show "origin/main:$EXP" 2>/dev/null |
    grep -m1 -oE '^estado: *[a-z-]+' | awk '{print $2}')"
  LOCAL="$(grep -m1 -oE '^estado: *[a-z-]+' "$EXP" | awk '{print $2}')"

  if [ "$PUBLICADO" != "cerrado" ]; then
    if [ "$LOCAL" = "cerrado" ]; then
      echo "· #$NUM  $EXP — cerrado en local pero SIN PUSHEAR (en origin/main: ${PUBLICADO:-no existe}). No se toca."
      PENDIENTES=$((PENDIENTES + 1))
    fi
    continue
  fi

  ESTADO_ISSUE="$(gh issue view "$NUM" --json state --jq .state 2>/dev/null)"
  if [ "$ESTADO_ISSUE" != "OPEN" ]; then
    YA=$((YA + 1))
    continue
  fi

  # El commit que dejó el expediente en `cerrado` en origin/main es, en el flujo
  # de este repo, el mismo que trae el arreglo.
  COMMIT="$(git log origin/main -1 --format='%h' -- "$EXP")"
  ID="$(grep -m1 -oE '^id: *BUG-[0-9]+' "$EXP" | awk '{print $2}')"

  if [ "$CERRAR" -eq 0 ]; then
    echo "· #$NUM  $ID  ($COMMIT)  — se cerraría"
    CERRADOS=$((CERRADOS + 1))
    continue
  fi

  MENSAJE="Arreglado y publicado en \`main\` (\`$COMMIT\`).

El detalle de qué pasaba, cómo se arregló y qué quedó pendiente de confirmar
está en el comentario anterior de la auditoría. Si algo sigue fallando, se
reabre: el expediente es \`$EXP\`.

<!-- issues-cerrar: $ID -->"

  if gh issue close "$NUM" --reason completed --comment "$MENSAJE" >/dev/null 2>&1; then
    echo "· #$NUM  $ID  ($COMMIT)  — cerrado"
    CERRADOS=$((CERRADOS + 1))
  else
    echo "· #$NUM  $ID  — ERROR al cerrar (¿permisos?, ¿issue de otro repo?). Queda abierto."
  fi
done

echo
echo "cerrados: $CERRADOS | esperando push: $PENDIENTES | ya estaban cerrados: $YA"
