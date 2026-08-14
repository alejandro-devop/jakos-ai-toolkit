---
name: cazabugs-init
description: Prepara este proyecto para la cadena de agentes de bugs — crea docs/bugs/ con el protocolo, la cola y un ENTORNO.md rellenado a partir de cómo corre realmente el proyecto. Usar cuando el usuario invoque /cazabugs-init, cuando pida instalar o configurar cazabugs, o cuando un agente de bugs se detenga porque falta docs/bugs/ENTORNO.md.
---

# Skill: cazabugs-init

Dejas este proyecto listo para la cadena `bug-reporter → bug-detective →
bug-hunter → bug-auditor`. Se corre **una vez por proyecto**, y otra vez cuando
el entorno cambie.

El trabajo de verdad no es copiar tres archivos: es **rellenar `ENTORNO.md`**.
De ese archivo depende que un agente verifique en la dirección correcta en vez
de irse media hora probando direcciones inventadas — que es el gasto que esta
cadena ya pagó una vez y no debería volver a pagar.

## Paso 1: mira si ya está

Si `docs/bugs/PROTOCOLO.md` existe, **no lo pises**. Puede tener ajustes del
usuario y expedientes vivos al lado. Di qué hay ya y ofrece:

- rellenar o corregir solo `ENTORNO.md` (lo habitual), o
- reinstalar todo, avisando de que se pierden los ajustes locales.

## Paso 2: copia el protocolo y la cola

De `plantillas/` (junto a este archivo) a `docs/bugs/`:

- `PROTOCOLO.md` — la escala de prioridad, los estados y la plantilla del
  expediente. Va tal cual: es el método, y no depende del proyecto.
- `COLA.md` — el índice vacío.

Si el proyecto guarda su documentación en otro sitio, pregunta dónde y usa esa
carpeta; luego dilo, porque los agentes buscan en `docs/bugs/`.

## Paso 3: averigua cómo corre el proyecto

Esta es la parte que importa. **Investiga primero, pregunta después**: llegar
con tres cosas averiguadas y una duda concreta vale más que un cuestionario.

Mira, según lo que haya: `README.md`, `CLAUDE.md`, `package.json` (o el archivo
de tareas equivalente), `docker-compose.yml`, `Makefile`, `.env.example`,
`.claude/launch.json`, y los scripts de arranque.

Lo que tienes que dejar respondido:

1. **En qué direcciones corre.** Puertos incluidos. Si hay varias piezas (sitio,
   panel, API), todas.
2. **Qué comando monta el entorno, y si sirve para un agente.** Casi nunca
   sirve: los que arrancan todo suelen quedarse en primer plano —cuelgan el
   turno— y ocupar los puertos que el usuario ya tiene abiertos. Nómbralos en
   «lo que NO se debe correr» con el motivo.
3. **Cómo conseguir datos de verdad** para pantallas de detalle. Comprueba si el
   listado se pinta en el cliente: si es así, el HTML servido no trae ni un
   enlace y hay que ir a la API o a la base de datos. Deja el comando exacto,
   probado.
4. **Qué comprobaciones existen**: tipos, linter, tests. Con su comando. Y
   cuáles NO conviene correr (un build que pisa la carpeta del servidor de
   desarrollo, una suite de diez minutos).
5. **Las trampas.** Lo que hace tropezar a quien llega nuevo. Búscalas de
   verdad: una IP o un host en la configuración que parezca el del sitio y sea
   el de la API; un archivo de entorno no versionado que valga distinto en cada
   máquina; un servidor que tarde tanto en compilar que parezca apagado.

**Comprueba lo que escribas.** Una dirección que no responde, un comando que no
existe o un identificador inventado en `ENTORNO.md` es peor que dejar el hueco:
el agente lo dará por bueno. Si algo no lo pudiste verificar, escríbelo como
pendiente y dilo.

Pregunta al usuario solo lo que no puedas verificar tú: qué servicios levanta
él, cuáles son suyos y no hay que tocar, y si hay algo que se rompe fácil.

## Paso 4: la sonda, si vale la pena

Si el proyecto tiene varias piezas o datos que hay que sacar de una API, escribe
un script corto que responda **todo** el ENTORNO de una vez —qué está en pie,
rutas, un identificador real— y anótalo en la sección «Sonda».

Es lo que más ahorra: un agente paga todo su contexto en cada turno, así que
diez preguntas sueltas cuestan diez veces lo que una sonda que las responde
juntas. Tres detalles que se aprendieron a golpes:

- Distingue **apagado** de **arriba pero compilando**. Con `curl`, el código de
  salida 7 es que no hay nadie y el 28 es que hay alguien ocupado. Confundirlos
  hace que un agente monte un entorno encima del que ya estaba.
- No des por sabida la máquina: nada de rutas absolutas ni de valores sacados
  de archivos que no están versionados. Que la raíz salga de la ubicación del
  propio script.
- `ss` y `lsof` no existen en todas partes; `curl` sí.

## Paso 5: cuéntale al usuario cómo se usa

Corto, y con lo que le toca a él:

- Cómo entra un bug: contárselo a Claude, que se lo pasa al `bug-reporter`.
- Que la cadena la encadena la sesión principal y puede frenar entre paso y
  paso.
- Que el `bug-hunter` **no commitea**: el arreglo se queda en el árbol de
  trabajo para que el auditor lo pruebe, y el commit lo decide él.
- Que el entorno lo levanta él, porque los agentes no lo hacen.
- Y qué quedó a medias en `ENTORNO.md`, si algo quedó.

## Lo que NO haces

- **No arreglas bugs ni registras ninguno.** Esto solo prepara el terreno.
- **No inventes el contenido de `ENTORNO.md`.** Un mapa equivocado es peor que
  ninguno: manda al agente a un sitio que no existe con toda confianza.
- No cambies el `PROTOCOLO.md`. Si a este proyecto le hace falta una regla
  distinta, va en `ENTORNO.md`.
- No instales dependencias ni levantes servicios para averiguar.
