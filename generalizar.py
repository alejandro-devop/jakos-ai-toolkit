#!/usr/bin/env python3
"""Despega de un proyecto concreto lo importado a plugins/cazabugs/.

La cadena de agentes nació dentro de moto-hertz-platform y ahí aprendió cosas
que valen en cualquier repositorio (el método) mezcladas con cosas que solo
valen allí (puertos, gestor de paquetes, rutas de scripts). Esto separa las dos.

Es repetible: se puede volver a copiar desde el proyecto de origen y correrlo
otra vez para traerse las mejoras que se hayan hecho allá.

Uso:  python3 generalizar.py        (desde la raíz de claude-kit)
"""
import pathlib
import re
import sys

RAIZ = pathlib.Path(__file__).parent
CAZA = RAIZ / "plugins" / "cazabugs"

# El bloque de entorno: lo único de los agentes que era 100% de aquel proyecto.
ENTORNO = """**Lo primero de todo: lee `docs/bugs/ENTORNO.md`.** Ahí está lo que no se
deduce mirando el código: en qué direcciones corre el proyecto, qué levanta el
usuario y qué no, cómo conseguir datos de verdad para las pantallas que los
piden, y las trampas propias de este repositorio. Si define una sonda, córrela:
te da todo eso en un turno. Sin ese archivo se van horas probando direcciones
inventadas — y si no existe, dilo y pide que se corra `/cazabugs-init`.

**Tú no levantas ni apagas servicios.** El entorno lo monta el usuario. Si algo
está caído, dilo en tu reporte y sigue con lo que no dependa de ello: perseguir
un entorno que no está es el gasto más caro y más inútil de todos."""

BULLET = """- No levantas ni apagas servicios del proyecto: eso es del usuario. No hagas
  `git stash` ni `git checkout --` — puede haber otras sesiones sobre el mismo
  árbol de trabajo."""

# (patrón, reemplazo). Los patrones son regex sobre el texto completo.
REGLAS = [
    # Bloques de entorno de cada agente → el bloque genérico. Cada agente tiene
    # su redacción, así que el patrón corta desde la frase que los tres
    # comparten hasta el final del párrafo siguiente.
    (r"Antes de abrir el navegador, corre `\./\.claude/entorno-bugs\.sh`(?:[^\n]|\n(?!\n))*"
     r"(?:\n\n(?:[^\n]|\n(?!\n))*?(?:ello\.|nada\.))?", ENTORNO),
    # Prohibiciones con puertos concretos → sin puertos.
    (r"- No matas los servidores del usuario \(3000 y 3001\)[^\n]*\n(?:  [^\n]*\n)*", BULLET + "\n"),
    (r"No matas los servidores del usuario \(3000 y 3001\) ni les corres `next build`\n"
     r"  encima\.", "No levantas ni apagas servicios del proyecto: eso es del usuario."),
    # Herramientas y estructura del monorepo de origen.
    (r"el `CLAUDE\.md` del paquete que vas a tocar", "el `CLAUDE.md` del área que vas a tocar"),
    (r"el `CLAUDE\.md` del paquete donde parece vivir el bug \(`web/`, `cms-admin/`,\n`backend/`\)\. Ahí hay",
     "el `CLAUDE.md` del área donde parece vivir el bug, si el proyecto los\ntiene. Ahí hay"),
    (r"lo mínimo del paquete que tocaste: `npx tsc --noEmit`, los tests si el\nárea los tiene",
     "lo mínimo que el proyecto ofrezca —tipos, linter, tests del área tocada;\n`ENTORNO.md` dice cuáles y con qué comando"),
    (r"el pipeline transforma el CSS y ya hubo arreglos que existían en el `\.scss` y no\nen la página\.",
     "compiladores y empaquetadores transforman, y un arreglo puede existir en el\nfuente y no en lo que se sirve."),
    # Rutas de scripts: en un plugin viven junto a su skill.
    (r"\(`\.claude/agents/bug-reporter\.md`\)", "(el subagente `bug-reporter` del plugin)"),
    (r"\.claude/skills/bugs-github/SKILL\.md", "la skill `bugs-github` del plugin"),
    (r"`\./\.claude/issues-bug\.sh`", "`issues-bug.sh` (junto a esta skill)"),
    (r"\./\.claude/issues-bug\.sh", "issues-bug.sh"),
    (r"`\./\.claude/issues-cerrar\.sh`", "`issues-cerrar.sh` (junto a esta skill)"),
    (r"\./\.claude/issues-cerrar\.sh", "issues-cerrar.sh"),
    # El área del expediente es de cada proyecto.
    (r"area: web            # web \| cms-admin \| backend \| infra \| varios",
     "area: <área>         # las que use este proyecto; ENTORNO.md las lista"),
]

# La sección de verificación del protocolo se reescribe entera: en el proyecto
# de origen son direcciones y comandos concretos, y aquí tiene que apuntar al
# ENTORNO.md que cada proyecto se genera.
VERIFICA_DESDE = "## Cómo se verifica en este proyecto"
VERIFICA_NUEVA = """## Cómo se verifica

Vale para el detective, el hunter y el auditor.

**Lo primero, siempre: `docs/bugs/ENTORNO.md`.** Ese archivo es de este
proyecto y de ningún otro: direcciones donde corre, qué levanta el usuario,
cómo conseguir datos de verdad, qué comprobaciones existen (tipos, linter,
tests) y las trampas propias del repositorio. Lo crea `/cazabugs-init` y se
corrige cuando algo cambie. Si define una sonda, córrela: te da todo eso en un
turno.

Si `ENTORNO.md` no existe, **para y pide que se corra `/cazabugs-init`**. Sin
él, un agente se pasa media hora probando direcciones inventadas — que es
exactamente el gasto que ese archivo existe para cortar.

**Tú no levantas ni apagas servicios.** El entorno lo monta el usuario. Si algo
está caído: dilo, y sigue con lo que no dependa de ello.

Y estas valen en cualquier proyecto:

- **La ventana del navegador puede estar oculta.** Entonces no hay capturas, no
  llegan clics ni teclas reales, y las transiciones CSS no avanzan. Se mide el
  DOM; para leer el estado final de una transición sirve
  `document.getAnimations().forEach(a => a.finish())`. Confundir eso con un
  fallo del arreglo es un error caro y fácil.
- **Los eventos de scroll no se disparan sin frames.** Con la ventana oculta,
  `window.scrollTo(...)` mueve la página pero no notifica a nadie: hay que
  acompañarlo de `window.dispatchEvent(new Event('scroll'))`.
- **Lo que solo pasa en un dispositivo real** (un teléfono de verdad, gestos
  táctiles, la cámara) no se finge: se razona sobre el código, se deja el
  criterio de prueba escrito y se le pide al usuario la confirmación final.
- **Lo que hay detrás de un login no se abre.** No se ingresan credenciales,
  nunca. Lo que solo se vea ahí dentro se entrega como pasos de prueba manual.
- **Nunca `git stash`, `git checkout --` ni nada que revierta el árbol** para
  "ver cómo era antes": puede haber otras sesiones trabajando sobre los mismos
  archivos. Para comprobar que el arreglo es lo que cambió las cosas, se recrea
  la condición vieja **en caliente** (reponer el atributo, la propiedad o el
  valor desde el navegador) y se mira si el bug reaparece.
- **Lo que se sirve no es lo que se escribió.** Compiladores y empaquetadores
  transforman: deduplican, reordenan, minifican. Comprueba el resultado real,
  no el fuente.
- **Comandos con rutas explícitas.** Nada de `git add .` ni de `pkill` amplio.
"""

DELATORES = re.compile(
    r"moto-hertz|localhost:\d|:300[0-9]|:8080|cms-admin|pnpm |next build|next dev|"
    r"npx tsc|yamaha|motorcycles|newsList|192\.168|entorno-bugs\.sh")

def main() -> int:
    objetivos = sorted(CAZA.rglob("*.md")) + sorted(CAZA.rglob("*.sh"))
    if not objetivos:
        print("No hay nada en plugins/cazabugs/ — ¿copiaste desde el proyecto?")
        return 1

    for f in objetivos:
        texto = original = f.read_text()
        for patron, nuevo in REGLAS:
            texto = re.sub(patron, nuevo, texto)
        if f.name == "PROTOCOLO.md" and VERIFICA_DESDE in texto:
            texto = texto[: texto.index(VERIFICA_DESDE)] + VERIFICA_NUEVA
        if texto != original:
            f.write_text(texto)
            print(f"  generalizado  {f.relative_to(RAIZ)}")

    print("\nRastros del proyecto de origen que quedan:")
    quedan = 0
    for f in objetivos:
        for n, linea in enumerate(f.read_text().splitlines(), 1):
            if DELATORES.search(linea):
                print(f"  {f.relative_to(RAIZ)}:{n}  {linea.strip()[:80]}")
                quedan += 1
    print("  ninguno" if not quedan else f"\n  {quedan} por revisar a mano")
    return 0

if __name__ == "__main__":
    sys.exit(main())
