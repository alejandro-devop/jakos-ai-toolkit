---
name: forja-init
description: Prepara este proyecto para la cadena de agentes de features — crea docs/features/ con el protocolo y el tablero, y deja resuelto el ENTORNO.md reutilizando el que ya exista. Usar cuando el usuario invoque /forja-init, cuando pida instalar o configurar forja, o cuando un agente de features se detenga porque falta el ENTORNO.md.
---

# Skill: forja-init

Dejas este proyecto listo para la cadena `feature-analista → feature-arquitecto
→ feature-constructor → feature-revisor`. Se corre **una vez por proyecto**, y
otra vez cuando el entorno cambie.

El trabajo de verdad no es copiar dos archivos: es **dejar resuelto el
`ENTORNO.md`**. De él depende que un agente verifique en la dirección correcta
en vez de irse media hora probando direcciones inventadas.

## Paso 1: mira si ya está

Si `docs/features/PROTOCOLO.md` existe, **no lo pises**. Puede tener ajustes del
usuario y expedientes vivos al lado. Di qué hay ya y ofrece: corregir solo el
`ENTORNO.md`, o reinstalar todo avisando de que se pierden los ajustes locales.

## Paso 2: el ENTORNO.md — antes que nada, búscalo

**Este es el paso donde se rompen cosas si vas rápido.** En orden:

1. **¿Existe `docs/bugs/ENTORNO.md`?** Entonces este proyecto ya corre la cadena
   de bugs y ese archivo **está en uso**. No lo copies, no lo muevas y **no lo
   modifiques**: los agentes de bugs lo leen tal cual. Los de features lo
   encuentran solos — su protocolo les dice que miren ahí si no hay uno en
   `docs/features/`.

   Léelo y comprueba que sigue siendo cierto. Si le falta algo que las features
   necesitan y los bugs no —la lista de áreas, los patrones vivos— **díselo al
   usuario y que él decida** si ampliarlo. Tú no lo tocas.

2. **¿Existe `docs/features/ENTORNO.md`?** Corrígelo si hace falta.

3. **¿No existe ninguno?** Créalo en `docs/features/ENTORNO.md` desde
   `plantillas/`, y sigue al paso 4 para llenarlo.

Si acabas encontrando **los dos**, dilo: hay que borrar uno. Dos mapas se
desincronizan y el equivocado manda a alguien a un sitio que no existe.

## Paso 3: copia el protocolo y el tablero

De `plantillas/` (junto a este archivo) a `docs/features/`:

- `PROTOCOLO.md` — los estados, la plantilla del expediente, la regla de las
  rebanadas y los presupuestos de turnos. Va tal cual: es el método.
- `TABLERO.md` — el índice vacío.

Si el proyecto guarda su documentación en otro sitio, pregunta dónde y usa esa
carpeta; luego dilo, porque los agentes buscan en `docs/features/`.

## Paso 4: averigua cómo corre el proyecto

Solo si tuviste que crear un `ENTORNO.md` nuevo. **Investiga primero, pregunta
después**: llegar con tres cosas averiguadas y una duda concreta vale más que un
cuestionario.

Mira, según lo que haya: `README.md`, `CLAUDE.md`, `package.json` (o el archivo
de tareas equivalente), `docker-compose.yml`, `Makefile`, `.env.example`,
`.claude/launch.json`, y los scripts de arranque.

Lo que tienes que dejar respondido:

1. **En qué direcciones corre.** Puertos incluidos, todas las piezas.
2. **Qué comando monta el entorno, y si sirve para un agente.** Casi nunca
   sirve: los que arrancan todo suelen quedarse en primer plano —cuelgan el
   turno— y ocupar los puertos que el usuario ya tiene abiertos. Nómbralos en
   «lo que NO se debe correr» con el motivo.
3. **Cómo conseguir datos de verdad** para pantallas de detalle. Comprueba si el
   listado se pinta en el cliente: si es así, el HTML servido no trae ni un
   enlace. Deja el comando exacto, probado.
4. **Las áreas** — los paquetes o capas de este repositorio. Es el campo `area:`
   de cada expediente; sin la lista, cada agente se inventa la suya.
5. **Qué comprobaciones existen**: tipos, linter, tests, con su comando. Y
   cuáles NO conviene correr.
6. **Los patrones vivos**, si ya se saben: el listado de referencia, el
   formulario de referencia. Esto es específico de features y le ahorra al
   arquitecto la mitad de su exploración.
7. **Las trampas.** Búscalas de verdad: una IP o un host en la configuración que
   parezca el del sitio y sea el de la API; un archivo de entorno no versionado
   que valga distinto en cada máquina; un servidor que tarde tanto en compilar
   que parezca apagado.

**Comprueba lo que escribas.** Una dirección que no responde o un identificador
inventado es peor que dejar el hueco: el agente lo dará por bueno. Si algo no lo
pudiste verificar, escríbelo como pendiente y dilo.

Pregunta al usuario solo lo que no puedas verificar tú: qué servicios levanta
él, cuáles son suyos y no hay que tocar, y si hay algo que se rompe fácil.

## Paso 5: la sonda, si vale la pena

Si el proyecto tiene varias piezas o datos que hay que sacar de una API, escribe
un script corto que responda **todo** el entorno de una vez y anótalo en la
sección «Sonda». Tres detalles que se aprendieron a golpes:

- Distingue **apagado** de **arriba pero compilando**. Con `curl`, el código de
  salida 7 es que no hay nadie y el 28 es que hay alguien ocupado. Confundirlos
  hace que un agente monte un entorno encima del que ya estaba.
- No des por sabida la máquina: nada de rutas absolutas ni de valores sacados de
  archivos que no están versionados. Que la raíz salga del propio script.
- `ss` y `lsof` no existen en todas partes; `curl` sí.

**Si ya hay una sonda de la cadena de bugs, reutilízala.** No escribas una
segunda que haga lo mismo.

## Paso 6: cuéntale al usuario cómo se usa

Corto, y con lo que le toca a él:

- Cómo entra una feature: contársela a Claude, que se la pasa al
  `feature-analista`.
- Que **el arquitecto no siempre entra** — solo si la feature introduce un
  concepto nuevo — y que esa decisión queda escrita con su razón.
- Que la cadena la encadena la sesión principal y **puede frenar entre paso y
  paso**: el estado vive en disco, así que el analista puede correr hoy y el
  constructor mañana.
- Que se construye **por rebanadas**, y que cada una se revisa antes de la
  siguiente.
- Que el `feature-constructor` **no commitea**: el cambio se queda en el árbol
  de trabajo para que el revisor lo pruebe, y el commit lo decide él.
- Que el entorno lo levanta él, porque los agentes no lo hacen.
- Y qué quedó a medias en el `ENTORNO.md`, si algo.

## Lo que NO haces

- **No modificas `docs/bugs/`.** Ni el `ENTORNO.md`, ni el protocolo, ni la
  cola. Si la cadena de bugs corre en este proyecto, tiene que seguir corriendo
  exactamente igual después de que pases por aquí.
- **No creas features ni las construyes.** Esto solo prepara el terreno.
- **No inventes el contenido del `ENTORNO.md`.** Un mapa equivocado es peor que
  ninguno: manda al agente a un sitio que no existe con toda confianza.
- No cambies el `PROTOCOLO.md`. Si a este proyecto le hace falta una regla
  distinta, va en el `ENTORNO.md`.
- No instales dependencias ni levantes servicios para averiguar.
