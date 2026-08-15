# jakos-ai-toolkit

Agentes y skills para Claude Code que se pueden llevar de un proyecto a otro.
Salen de trabajo real y están despegados del repositorio donde nacieron: lo que
es del proyecto se queda fuera, en un archivo que cada uno se genera.

## Qué hay dentro

### cazabugs

Cuatro agentes que se pasan un bug de mano en mano, y **ninguno se fía del
anterior**:

```
bug-reporter  →  bug-detective  →  bug-hunter  →  bug-auditor
 registra y       reproduce y       arregla,      intenta tumbarlo
 prioriza        localiza la causa  no cierra     por otra vía
```

Tres separaciones sostienen todo lo demás:

- **El detective no arregla**, ni una línea obvia. Si arregla, nadie mira ese
  código con ojos nuevos.
- **El hunter no cierra**, y deja el arreglo sin commitear para que se audite
  tal cual. Nadie se audita a sí mismo.
- **El auditor no toca código.** En el momento en que arregla lo que encontró,
  deja de estar mirando desde fuera. Lo que encuentra, lo devuelve.

Lo que se pasan no es contexto de conversación: es un expediente en
`docs/bugs/`, con cuatro secciones, que sobrevive a que cierres la sesión. La
prioridad se decide con una sola pregunta —*¿puede la persona terminar lo que
vino a hacer?*— y no por gravedad técnica, que es lo que con el tiempo vuelve
todo urgente.

Incluye `/bugs-github`, que trae los issues con etiqueta `bug` a la cola y, al
cerrarse, responde en el issue en el idioma de quien lo reportó.

### forja

El hermano de `cazabugs` para el otro lado del trabajo: construir algo que
todavía no existe.

```
feature-analista  →  feature-arquitecto  →  feature-constructor  →  feature-revisor
 problema, límites    qué existe ya y        una rebanada,          criterios, y qué
 y criterios          dónde va lo nuevo      sin commitear          se rompió al lado
```

Las mismas separaciones —el que planea no construye, el que construye no cierra,
el que revisa no toca código— más dos cosas que solo tienen sentido en features:

- **El arquitecto no siempre entra.** Una pregunta lo decide: *¿esto introduce
  un concepto nuevo, o se cuelga de uno que ya existe?* Lo que se cuelga va
  directo al constructor. La decisión queda escrita **con su razón**, porque
  equivocarse hacia el otro lado significa construir por segunda vez algo que ya
  estaba, y eso no se descubre hasta meses después.
- **Se construye por rebanadas verticales**, y cada una se revisa antes de la
  siguiente. El analista y el arquitecto corren una vez por feature; el
  constructor y el revisor giran una vez por rebanada.

Los criterios de aceptación se escriben **antes** de construir y nadie los
reescribe después: el revisor los lee literalmente, no la versión que el
constructor recuerde de ellos. Y cada agente lleva un presupuesto de turnos cuyo
fin no es cortarle el trabajo, sino que **se detenga y pregunte en vez de
insistir** — que es por donde se va el gasto.

## Instalar en un proyecto

```bash
claude plugin marketplace add alejandro-devop/jakos-ai-toolkit
claude plugin install cazabugs@jakos-ai-toolkit
claude plugin install forja@jakos-ai-toolkit
```

Los dos son independientes: puedes instalar uno sin el otro. Y dentro del
proyecto, una vez cada uno:

```
/cazabugs-init
/forja-init
```

Eso crea `docs/bugs/` y `docs/features/` con su protocolo y su índice, y —lo que
de verdad importa— un `ENTORNO.md` con las direcciones donde corre *ese*
proyecto, cómo conseguir datos de verdad y sus trampas propias. **Sin ese
archivo los agentes se pasan media hora probando direcciones inventadas**, que
es el gasto que este paso existe para cortar.

**Ese mapa es uno solo y se comparte.** Si ya corre una de las dos cadenas, la
otra lo encuentra y no lo toca: `/forja-init` detecta el `ENTORNO.md` de bugs,
lo reutiliza tal cual y no escribe nada en `docs/bugs/`.

Para probar antes de subir nada, el marketplace también acepta una ruta local:

```bash
claude plugin marketplace add ~/Developer/jakos-ai-toolkit
```

## Actualizar

```bash
claude plugin marketplace update jakos-ai-toolkit
claude plugin install cazabugs@jakos-ai-toolkit
claude plugin install forja@jakos-ai-toolkit
```

Los `-init` no pisan lo que ya esté: si encuentran un `PROTOCOLO.md`, ofrecen
tocar solo el `ENTORNO.md`. Los expedientes, la cola y el tablero son tuyos y no
se tocan nunca.

## Cómo se usa, una vez instalado

**Un bug:**

1. Se lo cuentas a Claude, o corres `/bugs-github`.
2. Va al `bug-reporter`, que lo registra y le pone prioridad.
3. Le dices que siga, y la sesión principal encadena detective → hunter →
   auditor. **Puedes frenar entre paso y paso**: el estado vive en disco.
4. El auditor cierra y te deja un resumen de qué pasaba y cómo se arregló.
5. El commit lo haces tú, con el bug ya cerrado.

**Una feature:**

1. Se la cuentas a Claude, que se la pasa al `feature-analista`.
2. Vuelve con el alcance, los criterios, las rebanadas y —si las hay— las
   decisiones que tienes que tomar tú. **Ahí es donde te toca responder**, y es
   a propósito: una decisión resuelta ahora vale por media hora de constructor
   bloqueado después.
3. Si la feature introduce un concepto nuevo, entra el arquitecto y averigua qué
   ya existe. Si se cuelga de algo que ya está, se lo salta.
4. Constructor y revisor giran por rebanada. Cada vuelta te deja algo usable.
5. El commit lo haces tú.

**El entorno lo levantas tú.** Los agentes no arrancan ni apagan servicios: si
algo está caído lo dicen y siguen con lo que no dependa de ello.

## Mantener esto

`cazabugs` nació dentro de un proyecto y sigue mejorando allí. Para traerse las
mejoras: copiar los archivos del proyecto de origen a `plugins/cazabugs/` y
correr

```bash
python3 generalizar.py
```

que quita lo que sea de aquel repositorio (puertos, gestor de paquetes, rutas
de scripts) y avisa de lo que se le escape. Lo que no detecte, se revisa a
mano: **un agente con un mapa equivocado va con toda confianza a un sitio que
no existe**, y eso hace más daño que no tener mapa.
