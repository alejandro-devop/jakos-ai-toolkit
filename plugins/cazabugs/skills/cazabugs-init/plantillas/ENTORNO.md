# Entorno — lo que un agente no puede deducir del código

Este archivo es de **este** proyecto. Lo lee el detective, el hunter y el
auditor antes de tocar el navegador, y existe para cortar el gasto más caro de
todos: un agente probando direcciones inventadas, montando un entorno que ya
estaba puesto o persiguiendo uno que no está.

Cuando algo de aquí deje de ser cierto, corrígelo. Un mapa desactualizado hace
más daño que no tener mapa.

> Generado por `/cazabugs-init`. Lo que sigue son las preguntas que hay que
> dejar respondidas; borra las que no apliquen y no dejes ninguna a medias.

## Dónde corre

| Servicio | Dirección | Quién lo levanta |
|---|---|---|
| _(p. ej. el sitio)_ | `http://localhost:____` | el usuario |
| _(p. ej. el panel)_ | `http://localhost:____` | el usuario |
| _(p. ej. la API)_ | `http://localhost:____` | el usuario |

**Los agentes no levantan ni apagan nada.** Si algo está caído: se dice en el
reporte y se sigue con lo que no dependa de ello.

Para mirar una pantalla, se abre una pestaña con
`preview_start {url: "<la dirección de arriba>"}` — es una pestaña de
navegador, no arranca ningún servidor.

## Lo que NO se debe correr

_(Los comandos que montan el entorno entero, se quedan en primer plano o pisan
lo que el usuario tiene abierto. Nómbralos aquí: existen y parecen lo correcto,
y por eso hay que decir explícitamente que no.)_

- `____`

## Cómo conseguir datos de verdad

_(Si hay pantallas de detalle cuyo identificador no se puede adivinar —fichas,
artículos, pedidos—, di aquí cómo obtener uno real. Un identificador inventado
da 404 y parece un bug que no existe. Ojo si la lista se pinta en el cliente:
entonces el HTML servido no trae ni un enlace y hay que ir a la API o a la base
de datos.)_

```
____
```

## Rutas o pantallas

_(La lista, o el comando que la genera.)_

```
____
```

## Comprobaciones que existen

| Qué | Comando |
|---|---|
| Tipos | `____` |
| Linter | `____` |
| Tests | `____` |

_(Y lo que NO hay que correr: builds que pisan la carpeta de un servidor de
desarrollo, suites que tardan diez minutos, migraciones destructivas.)_

## Trampas de este repositorio

_(Lo que hace tropezar a alguien que llega nuevo, con el porqué. Ejemplos
reales de otros proyectos: una IP de la red en la configuración que parece la
del sitio y es la de la API; un servidor de desarrollo que tarda tanto en
compilar que parece apagado; un archivo de entorno que no está versionado y
vale distinto en cada máquina.)_

- `____`

## Sonda

_(Opcional pero es lo que más ahorra: un script que responda todo lo anterior
de una sola vez, con el estado real en el momento de correrlo. Si existe,
ponlo aquí y los agentes lo correrán en vez de averiguarlo a trozos.)_

```
____
```
