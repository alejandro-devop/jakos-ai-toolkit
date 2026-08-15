# Protocolo de features

Cuatro agentes se pasan una feature de mano en mano. Este documento es lo único
que comparten: dónde vive una feature, cómo se parte, en qué estados puede estar
y qué escribe cada uno. Si algo de aquí cambia, cambia para los cuatro.

Los agentes: `feature-analista` → `feature-arquitecto` → `feature-constructor` →
`feature-revisor`.

**Dos de los cuatro no siempre corren.** El arquitecto se salta cuando la feature
se cuelga de algo que ya existe; el revisor, nunca — pero revisa por rebanada, no
por feature. Más abajo está la regla exacta.

## Dónde vive una feature

- `docs/features/TABLERO.md` — el índice. Una fila por feature, con su estado y
  en qué rebanada va. No es el contenido.
- `docs/features/FEAT-NNN-<slug>.md` — el expediente. Cuatro secciones que se
  llenan en orden. Nadie borra lo que escribió otro: se agrega debajo.

El `NNN` es correlativo, tres cifras. Para saber cuál toca se listan los
archivos existentes y se toma el mayor + 1 **justo antes de escribir** — puede
haber varias sesiones sobre el mismo working tree. Si el archivo ya existe, se
pasa al siguiente.

Por la misma razón: `TABLERO.md` se relee **justo antes** de modificarlo, nunca
se reescribe entero desde una copia vieja en memoria, y se toca solo la fila
propia.

## La pregunta que parte el trabajo

En bugs la pregunta es *¿puede la persona terminar lo que vino a hacer?*, y
sirve para no inflar prioridades. Aquí la pregunta es otra, y sirve para no
inflar el alcance:

> **¿Qué es lo mínimo que ya le sirve a alguien?**

Eso es la primera rebanada. Lo demás son las siguientes, o no son.

Una rebanada es **vertical**: funciona de punta a punta y alguien la puede usar.
«El modelo de datos» no es una rebanada; «se puede crear una cita y verla en la
lista, sin editarla ni cancelarla» sí. Si una rebanada no se puede probar sola,
está mal cortada.

Tres o cuatro rebanadas por feature es sano. Si salen ocho, la feature son dos
features y hay que decirlo.

## ¿Hace falta el arquitecto?

Una pregunta, no una estimación de tamaño:

> **¿Esto introduce un concepto nuevo, o se cuelga de uno que ya existe?**

- **Se cuelga** — un campo más en un formulario que existe, una columna en una
  tabla que existe, un filtro sobre un listado que existe. El analista anota
  dónde se cuelga y la cadena va **analista → constructor → revisor**.
- **Introduce** — una entidad nueva, una pantalla que no tiene hermana, algo que
  toca capas que hoy no se hablan. Entra el arquitecto.

Ante la duda, entra. Equivocarse hacia el arquitecto cuesta unos turnos;
equivocarse hacia el otro lado cuesta construir por segunda vez algo que ya
estaba, y eso no se descubre hasta meses después.

El campo `arquitecto:` del front-matter lleva `sí` o `no` **con su razón en una
línea**. Sin razón no vale: es la decisión que más caro sale si se toma por
inercia.

## Estados

```
pedido ──▶ especificado ──▶ planeado ──▶ en-construcción ──▶ entregado
              │   │                            │    ▲
              │   └────────(sin arquitecto)─────┘    │
              │                              en-revisión
              │                                   │
              │                              devuelto (el revisor no la da por buena)
              └──▶ bloqueado ──▶ descartado
```

| Estado | Quién lo pone | Qué significa |
|---|---|---|
| `pedido` | usuario | Está contado, nadie lo ha ordenado todavía. |
| `especificado` | analista | Problema, alcance, criterios y rebanadas escritos. Las decisiones del usuario, resueltas o marcadas. |
| `bloqueado` | analista | Falta una decisión que no es del agente. Nadie avanza hasta que se responda. |
| `planeado` | arquitecto | Rebanadas con rutas concretas y la implementación de referencia identificada. |
| `en-construcción` | constructor | Trabajando una rebanada. |
| `en-revisión` | constructor | Rebanada terminada y verificada por quien la hizo. **Sin commitear.** |
| `devuelto` | revisor | La rebanada no pasó. Vuelve al constructor con el motivo. |
| `entregado` | revisor | Todas las rebanadas revisadas y aceptadas. |
| `descartado` | usuario | No se hace. Se anota por qué. |

El estado del front-matter es el de la **feature**. El de cada rebanada va en la
tabla de la sección 2 (o de la 1, si no hubo arquitecto). Una feature en
`en-construcción` puede tener dos rebanadas aceptadas y una a medias: eso se lee
en la tabla, no en el front-matter.

El constructor **no commitea**: deja el cambio en el árbol de trabajo para que el
revisor lo pruebe tal cual, y el commit lo decide el usuario.

## Presupuesto de turnos

Un agente paga todo su contexto en cada turno. El gasto no está en lo que
piensa, está en cuántas veces se detiene a buscar algo. Y lo que se descontrola
no es el agente que no sabe: es el que **insiste**.

| Agente | Turnos | Al llegar al tope |
|---|---|---|
| analista | ~12 | Escribe lo que tengas y pon `bloqueado` con las preguntas. |
| arquitecto | ~30 | Escribe el plan hasta donde llegaste y di qué no encontraste. |
| constructor | ~45 por rebanada | Para, deja el árbol en un estado coherente y reporta qué falta. |
| revisor | ~25 | Reporta lo revisado y lo que quedó sin revisar. **No des por buena una rebanada que no terminaste de mirar.** |

No son límites duros y no hay nadie contándolos: son la señal de que algo que
debería estar escrito no lo está. **Un agente que se detiene y pregunta cuesta
una fracción de uno que sigue con confianza** — y de paso deja visible el hueco
del `ENTORNO.md`, que si no se paga en silencio cada vez.

Si te falta una herramienta para hacerlo bien, para y dilo en tu reporte. No la
vas a poder pedir a mitad de camino, y un rodeo improvisado entrega una
comprobación floja sin que nadie se entere.

## Plantilla del expediente

```markdown
---
id: FEAT-000
titulo: <una línea, en lenguaje de usuario, no de código>
estado: pedido
arquitecto: sí | no    # con su razón en la sección 1
area: <área>           # las que use este proyecto; ENTORNO.md las lista
pedido: AAAA-MM-DD
actualizado: AAAA-MM-DD
---

# FEAT-000 — <título>

## 1. El pedido — feature-analista

**Resumen para quien siga:** (2 líneas: qué se va a construir y cuál es la
primera rebanada. Es lo único que lee quien no va a trabajar sobre esta sección.)

**Qué problema resuelve:** (el problema, no la solución)
**Para quién:** (quién lo va a usar y en qué momento)
**Palabras del usuario:** (cita textual; no la reinterpretes)

**Fuera de alcance:** (lo que alguien podría dar por incluido y NO lo está.
Esta lista vale más que la de dentro.)

**Criterios de aceptación:** (comprobables. "Se ve bien" no es un criterio;
"al guardar sin título, el formulario no envía y marca el campo" sí.)
- [ ] …

**Rebanadas:** (verticales, cada una usable sola)
| # | Qué hace | Estado |
|---|---|---|
| 1 | … | pendiente |

**¿Arquitecto? sí/no** porque …
(si es `no`: de qué existente se cuelga, con su ruta)

**Decisiones que no son mías:** (cada una con opciones y consecuencias, o
"resuelta: <lo que dijo el usuario>")

## 2. El plan — feature-arquitecto

**Resumen para el constructor:** (3 líneas: cuál es la implementación de
referencia, dónde va lo nuevo, y qué NO hay que crear porque ya existe.)

**Qué ya existe:** (lo que hace esto o la mitad de esto, con `archivo:línea`.
Si no existe nada, dilo explícitamente — es información.)
**Implementación de referencia:** (el módulo que hay que imitar, y por qué ese)
**Dónde va lo nuevo:** (rutas concretas, archivo por archivo)
**Lo que NO hay que crear:** (lo que se parece pero ya está resuelto)
**Por dónde NO va:** (lo que se descartó, para que nadie lo reconsidere)

**Rebanadas, con rutas:**
| # | Qué hace | Archivos | Criterios que cierra | Estado |
|---|---|---|---|---|
| 1 | … | … | … | pendiente |

## 3. Construcción — feature-constructor

*(una entrada por rebanada, se agregan debajo)*

### Rebanada N

**Resumen para el revisor:** (3 líneas: qué se construyó, dónde, y qué es lo
más probable que haya roto.)

**Qué se construyó:** (rutas y qué se hizo en cada una)
**Por qué así:** (y qué alternativa se descartó)
**Verificación:** (comandos y salidas literales)
**Criterios que cierra:** (cuáles de la sección 1, uno por uno, con evidencia)
**Riesgos:** (qué podría haber roto esto)
**Estado del árbol:** (sin commitear)

## 4. Revisión — feature-revisor

*(una entrada por rebanada)*

### Rebanada N

**Criterios, uno por uno:** (contra la sección 1, no contra el resumen del
constructor)
**Qué se rompió al lado:** (cómo se buscó, no solo el resultado)
**Estados sin construir:** (vacío, cargando, error, sin permisos, texto largo,
móvil — cuáles aplican y cuáles faltan)
**¿Duplica algo que ya existía?** (contra la sección 2)
**Veredicto:** aceptada | devuelta — porque …
**Para el usuario:** (qué se puede hacer ahora que antes no, en dos párrafos, y
los pasos para probarlo a mano)
```

## Cómo no gastar de más

Un agente paga **todo su contexto en cada turno**: cada llamada a una
herramienta vuelve a leer la conversación entera.

- **Lee del expediente solo lo tuyo.** Cada sección abre con un resumen
  precisamente para eso. El arquitecto lee la 1 completa. El constructor, el
  resumen de la 1, los criterios, y la 2 completa. El revisor, los criterios de
  la 1 —completos y literales, esos no se resumen— más la 3 de su rebanada. Lo
  demás está ahí si hace falta: se va a buscar cuando haga falta, no por si
  acaso.
- **El arquitecto entrega rutas, no prosa.** Un plan que dice «seguir el patrón
  de las otras secciones» obliga al constructor a repetir toda la exploración y
  tira a la basura lo que costó el paso anterior. Un plan que dice «copia estos
  tres archivos» lo hace arrancar en el turno dos. Es la diferencia entre que el
  arquitecto ahorre o sobre.
- **Una sonda que mide seis cosas cuesta lo mismo que una que mide una.**
  Agrupa. Antes de lanzar una medición, pregúntate qué más vas a querer saber
  cuando veas el resultado, y mídelo ya.
- **Lee archivos por rangos** cuando sabes qué línea te interesa, y acota lo que
  vuelcas del navegador (`max_chars`). Un volcado entero se queda en tu contexto
  hasta el final.
- **No repitas trabajo que ya está escrito.** Si el arquitecto dejó localizada
  la referencia, el constructor no la busca otra vez. La revisión independiente
  sí es a propósito, y esa no se toca.

## Cómo se verifica

Vale para el arquitecto, el constructor y el revisor.

**Lo primero, siempre: el `ENTORNO.md` de este proyecto.** Búscalo en
`docs/features/ENTORNO.md` y, si no está ahí, en `docs/bugs/ENTORNO.md` — es el
mismo mapa y puede haberlo dejado la cadena de bugs. **El que encuentres, no lo
modifiques**: puede estar en uso por otros agentes.

Ahí está lo que no se deduce leyendo código: en qué direcciones corre el
proyecto, qué levanta el usuario, cómo conseguir datos de verdad, qué
comprobaciones existen (tipos, linter, tests) y las trampas propias del
repositorio. Si define una sonda, córrela: te da todo eso en un turno.

Si no existe en ninguno de los dos sitios, **para y pide que se corra
`/forja-init`**. Sin él se van horas probando direcciones inventadas.

**Tú no levantas ni apagas servicios.** El entorno lo monta el usuario. Si algo
está caído: dilo, y sigue con lo que no dependa de ello.

Y estas valen en cualquier proyecto:

- **La ventana del navegador puede estar oculta.** Entonces no hay capturas, no
  llegan clics ni teclas reales, y las transiciones CSS no avanzan. Se mide el
  DOM; para leer el estado final de una transición sirve
  `document.getAnimations().forEach(a => a.finish())`.
- **Los eventos de scroll no se disparan sin frames.** Con la ventana oculta,
  `window.scrollTo(...)` mueve la página pero no notifica a nadie: hay que
  acompañarlo de `window.dispatchEvent(new Event('scroll'))`.
- **Lo que solo pasa en un dispositivo real** no se finge: se razona sobre el
  código, se deja el criterio de prueba escrito y se le pide al usuario la
  confirmación final.
- **Lo que hay detrás de un login no se abre.** No se ingresan credenciales,
  nunca. Lo que solo se vea ahí dentro se entrega como pasos de prueba manual.
- **Nunca `git stash`, `git checkout --` ni nada que revierta el árbol.** Puede
  haber otras sesiones trabajando sobre los mismos archivos.
- **Lo que se sirve no es lo que se escribió.** Compiladores y empaquetadores
  transforman. Comprueba el resultado real, no el fuente.
- **Comandos con rutas explícitas.** Nada de `git add .` ni de `pkill` amplio.
