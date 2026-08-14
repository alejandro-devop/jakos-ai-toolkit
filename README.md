# claude-kit

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

## Instalar en un proyecto

```bash
claude plugin marketplace add alejandro-devop/claude-kit
claude plugin install cazabugs@claude-kit
```

Y dentro del proyecto, una vez:

```
/cazabugs-init
```

Eso crea `docs/bugs/` con el protocolo, la cola y —lo que de verdad importa—
un `ENTORNO.md` con las direcciones donde corre *ese* proyecto, cómo conseguir
datos de verdad y sus trampas propias. **Sin ese archivo los agentes se pasan
media hora probando direcciones inventadas**, que es el gasto que este paso
existe para cortar.

Para probar antes de subir nada, el marketplace también acepta una ruta local:

```bash
claude plugin marketplace add ~/Developer/claude-kit
```

## Actualizar

```bash
claude plugin marketplace update claude-kit
claude plugin install cazabugs@claude-kit
```

`/cazabugs-init` no pisa lo que ya esté: si encuentra un `PROTOCOLO.md`, ofrece
tocar solo el `ENTORNO.md`. Los expedientes y la cola son tuyos y no se tocan
nunca.

## Cómo se usa, una vez instalado

1. Le cuentas el bug a Claude, o corres `/bugs-github`.
2. Va al `bug-reporter`, que lo registra y le pone prioridad.
3. Le dices que siga, y la sesión principal encadena detective → hunter →
   auditor. **Puedes frenar entre paso y paso**: el estado vive en disco.
4. El auditor cierra y te deja un resumen de qué pasaba y cómo se arregló.
5. El commit lo haces tú, con el bug ya cerrado.

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
