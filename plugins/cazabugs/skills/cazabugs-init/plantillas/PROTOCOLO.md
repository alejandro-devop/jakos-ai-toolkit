# Protocolo de bugs

Cuatro agentes se pasan un bug de mano en mano. Este documento es lo único que
comparten: dónde vive un bug, cómo se prioriza, en qué estados puede estar y qué
escribe cada uno. Si algo de aquí cambia, cambia para los cuatro.

Los agentes: `bug-reporter` → `bug-detective` → `bug-hunter` → `bug-auditor`
(`.claude/agents/`).

## Dónde vive un bug

- `docs/bugs/COLA.md` — la cola. Una fila por bug, ordenada por prioridad y,
  dentro de la misma prioridad, por antigüedad. Es el índice, no el contenido.
- `docs/bugs/BUG-NNN-<slug>.md` — el expediente. Todo lo que se sabe del bug, en
  cuatro secciones que se van llenando en orden. Nadie borra lo que escribió
  otro: se agrega debajo.

El `NNN` es correlativo y con tres cifras. Para saber cuál toca, se listan los
archivos existentes y se toma el mayor + 1 **justo antes de escribir** — hay
varias sesiones sobre este mismo working tree y dos agentes pueden estar
reservando número a la vez. Si el archivo ya existe, se pasa al siguiente.

Por la misma razón: `COLA.md` se relee **justo antes** de modificarla, nunca se
reescribe entera desde una copia vieja en memoria, y se toca solo la fila
propia.

## Prioridad: qué tan bloqueante es para quien lo está usando

El eje es uno solo: **¿puede la persona terminar lo que vino a hacer?** No es la
gravedad técnica ni lo feo que se ve.

| | Significado | Regla práctica |
|---|---|---|
| **P0** | No puede. Y no hay rodeo. | El sitio o el panel no cargan, no se puede publicar, se pierde o se corrompe información, el negocio deja de recibir contactos. Se atiende ya. |
| **P1** | No puede por el camino normal, pero hay un rodeo incómodo. | Un botón muerto que tiene un gemelo en otra pantalla; un formulario que falla y obliga a repetir todo. |
| **P2** | Puede terminar, pero con fricción o confusión. | Algo se ve mal, un texto engaña, algo tarda de más sin llegar a romper. |
| **P3** | No le afecta a la tarea. | Detalle visual, inconsistencia menor, deuda que solo ve quien hizo el código. |

Dos correcciones al resultado:

- **A cuánta gente le pasa** desempata dentro del mismo nivel, no cambia de
  nivel. Un P1 en iPhone (la mitad del tráfico) va antes que un P1 que solo
  ocurre con una combinación rarísima de filtros.
- **Un bug de datos sube un nivel.** Que se pierda o se guarde mal algo que la
  persona escribió pesa más que la molestia del momento, porque el daño queda.

Si el reporte no alcanza para decidir entre dos niveles, se toma el más bajo de
los dos y se anota en el expediente qué haría falta para subirlo. Prioridad
inflada es prioridad inútil.

## Estados

```
reportado ──▶ analizado ──▶ arreglado ──▶ cerrado
    │             │              ▲            
    │             │              └── devuelto ◀── (el auditor no lo da por bueno)
    │             └──▶ no-reproducible
    └──▶ descartado
```

| Estado | Quién lo pone | Qué significa |
|---|---|---|
| `reportado` | reporter | Está descrito y priorizado. Nadie lo ha confirmado todavía. |
| `analizado` | detective | Reproducido, con causa raíz localizada y una propuesta de arreglo. Listo para el hunter. |
| `no-reproducible` | detective | No se logró reproducir. Queda escrito qué se intentó, para que el usuario aporte lo que falta. |
| `arreglado` | hunter | El cambio está en el árbol de trabajo, verificado por quien lo hizo. **Sin commitear.** |
| `devuelto` | auditor | El arreglo no pasó la auditoría. Vuelve al hunter con el motivo. |
| `cerrado` | auditor | Arreglo confirmado por una vía distinta a la del detective. |
| `descartado` | usuario | No era un bug, o se decide no arreglarlo. Se anota por qué. |

El hunter **no commitea**: deja el cambio en el árbol de trabajo para que el
auditor lo pruebe tal cual, y el commit lo decide el usuario después de cerrar.

## Plantilla del expediente

```markdown
---
id: BUG-000
titulo: <una línea, en lenguaje de usuario, no de código>
estado: reportado
prioridad: P2
area: <área>         # las que use este proyecto; ENTORNO.md las lista
reportado: AAAA-MM-DD
actualizado: AAAA-MM-DD
github_issue: 12     # solo si vino de un issue de GitHub — ver abajo
---

# BUG-000 — <título>

## 1. Reporte — bug-reporter

**Resumen para el detective:** (2 líneas: qué falla y dónde. Es lo único que
lee quien no va a trabajar sobre esta sección.)

**Qué pasa:**
**Dónde:** (URL, pantalla, componente si se sabe)
**Cómo llegar:** (pasos numerados)
**Qué debería pasar:**
**Entorno:** (dispositivo, navegador, si aplica; "no se dijo" es una respuesta)
**A quién le pasa:** (todos / solo móvil / solo el admin / …)
**Impacto:** (qué no puede hacer la persona — esto es lo que justifica la prioridad)
**Prioridad: PN** porque …
**Palabras del usuario:** (cita textual; no la reinterpretes)
**Origen:** (quién lo contó y por dónde; si fue un issue, su URL y las rutas de
las capturas bajadas a `docs/bugs/adjuntos/`)

## 2. Confirmación y análisis — bug-detective

**Resumen para el hunter:** (3 líneas: qué falla, la causa raíz con
`archivo:línea`, y qué hay que cambiar.)
**Vía de comprobación que usé:** (una línea — el auditor necesita saber cuál
**no** repetir, y es lo único que leerá de esta sección.)

**¿Se reprodujo?**
**Cómo, exactamente:** (pasos y evidencia literal: salidas, mediciones, logs)
**Causa raíz:** (`archivo:línea` y por qué eso produce esto)
**Alcance:** (qué más está tocado por el mismo defecto)
**Por dónde NO va:** (lo que se descartó, para que nadie lo repita)
**Propuesta de arreglo:** (sin aplicarla)
**Cómo se prueba que quedó:** (criterio verificable, no "revisar que se vea bien")

## 3. Arreglo — bug-hunter

**Resumen para el auditor:** (3 líneas: qué se cambió, dónde, y qué es lo que
habría que tumbar para probar que no sirve.)

**Qué se cambió:** (rutas y qué se hizo en cada una)
**Por qué así:** (y qué alternativa se descartó)
**Verificación:** (comandos y salidas literales)
**Riesgos:** (qué podría haber roto esto)
**Estado del árbol:** (sin commitear / commit `hash` si el usuario lo pidió)

## 4. Auditoría — bug-auditor

**Reproducción por otra vía:** (cuál, y por qué es distinta a la del detective)
**¿Aparecía antes del arreglo?** (cómo se comprobó)
**¿Sigue apareciendo?**
**Regresiones revisadas:**
**Veredicto:** cerrado | devuelto — porque …
**Para el usuario:** (qué pasaba y cómo se arregló, en dos párrafos)
```

### Bugs que vienen de un issue de GitHub

Los issues con label `bug` del repo entran a la cola con `/bugs-github`
(`la skill `bugs-github` del plugin`), que se los reparte al `bug-reporter`.

El campo `github_issue:` del front-matter no es decoración: es el único vínculo
que sobrevive entre sesiones, y es lo que la sonda mira para no volver a
registrar un issue que ya tiene expediente. Sin él se crean duplicados. Si el
bug no vino de GitHub, el campo no va.

**El viaje de vuelta va en dos tiempos, y separarlos es a propósito:**

1. **El `bug-auditor` comenta** en el issue cuando cierra el bug — qué pasaba,
   cómo se arregló y qué quedó sin comprobar — en lenguaje de quien lo reportó,
   sin rutas de archivo. No comenta si devolvió el bug. Termina con la marca
   `<!-- bug-auditor: BUG-NNN -->`, que es lo que evita el comentario doble en
   una segunda auditoría.
2. **`issues-cerrar.sh` (junto a esta skill) cierra**, después del push. En seco por
   defecto; con `--cerrar` lo hace de verdad.

Entre los dos hay un hueco de tiempo real: cuando el auditor termina, el arreglo
**no está commiteado** —su protocolo se lo prohíbe— y puede pasar un rato largo
hasta que se pushee. Cerrar el issue ahí anunciaría "resuelto" con el código
viviendo en una sola máquina.

Por eso el script no decide con el árbol de trabajo, sino con el expediente **tal
como está en `origin/main`**: si allí dice `estado: cerrado`, el commit que lo
dejó así está publicado, y como el arreglo y el expediente van en el mismo
commit, el código también. Un expediente cerrado solo en local aparece listado
como "esperando push" y no se toca.

Que la auditoría deje pendientes (un teléfono real, un panel con sesión) **no
impide cerrar**: se cierra como `completed` y los pendientes van dichos en el
comentario. Cerrado es "probado en todo lo que aquí se puede probar, y lo demás
está escrito", igual que en el expediente. Si el reportante contesta con algo que
lo tumba, se reabre — que es barato, y es la razón de que esto pueda ser
automático.

## Cómo no gastar de más

Un agente paga **todo su contexto en cada turno**: cada llamada a una
herramienta vuelve a leer la conversación entera. Así que lo caro no es lo que
piensa, es cuántas veces se detiene a pedir algo y cuánto arrastra encima.
Medido sobre la primera corrida de esta cadena, esto es lo que la abarataría a
la mitad sin quitar ni una comprobación:

- **Una sonda que mide seis cosas cuesta lo mismo que una que mide una.**
  Agrupa. Los cinco umbrales de una rejilla, los diez enlaces, el antes y el
  después: en un solo script que devuelva un objeto con todo, no en cinco
  llamadas. Antes de lanzar una medición, pregúntate qué más vas a querer saber
  cuando veas el resultado, y mídelo ya.
- **Lee del expediente solo lo tuyo.** Cada sección abre con un resumen
  precisamente para eso. El detective lee la 1 completa. El hunter, el resumen
  de la 1 y la 2 completa. El auditor, los resúmenes de la 1 y la 2 más "la vía
  que usé" del detective, y la 3 completa. Lo demás está ahí si lo necesitas —
  ve a buscarlo cuando lo necesites, no por si acaso.
- **Lee archivos por rangos** cuando sabes qué línea te interesa, y acota lo que
  vuelcas del navegador (`max_chars`). Un volcado entero se queda en tu contexto
  hasta el final de la tarea.
- **No repitas trabajo que ya está escrito.** Si el detective dejó la
  reproducción documentada, el hunter no la rehace desde cero: comprueba el
  después y la contraprueba. La verificación independiente del auditor sí es a
  propósito, y esa no se toca.

Y si te falta una herramienta que necesitas para hacerlo bien: **para y dilo en
tu reporte**. No la vas a poder pedir a mitad de camino, y un rodeo improvisado
entrega una comprobación floja sin que nadie se entere.

## Cómo se verifica

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
