# Caso 01 · Filamenta Lab — el encargo

> Negocio y datos **ficticios**, creados para la asignatura. Es tu mismo caso de la J3.

## Qué ha pasado desde la J3

En la J3 limpiaste el parte en un cuaderno y contestaste tres preguntas. Filamenta Lab quiere saber, cada mañana y sin abrir un cuaderno, qué impresoras y qué piezas le hacen perder dinero. Y ha instalado sensores de temperatura en las boquillas.

Ahora conviertes aquel cuaderno en un **lakehouse** de verdad, en tu propio repositorio, y publicas un **portal** que
cuenta lo que has hecho. Cómo preparar el repositorio y el ciclo de trabajo de cada bloque: [README.md](README.md).

## Lo que tienes al empezar

- En bronce, el parte de la J3: `lakehouse/bronce/parte/fecha_carga=2026-03-28/`.
- En `dbt/models/plata/stg_parte.sql`, la limpieza que hiciste en la J3, con unos tests básicos (`_plata.yml`, `dbt/tests/`).
- `dbt build` en verde. La capa oro, vacía: la construyes tú.
- En `paginas/`, las cuatro páginas del portal que escribirás, cada una con un guion de lo que debe contar.

**Bronce no se toca nunca**: todo arreglo va en plata.

---

## Bloque 1 · La remesa nueva · rama `remesa`

1. `python herramientas/sistema_simulado.py remesa`: llega una entrega nueva del parte en `bronce/parte/fecha_carga=2026-04-11/` (unos diez días más de trabajos).
2. `dbt build --project-dir dbt --profiles-dir dbt`. El taller cambió una de las básculas a mitad de mes. Algún test va a protestar: averigua qué filas y de qué impresora.
3. Arregla `dbt/models/plata/stg_parte.sql` hasta que `dbt build` quede en verde y el problema esté resuelto (no siempre hay un test que lo grite: a veces tienes que escribirlo tú). Deja un comentario en el SQL: **qué** venía mal y **por qué** lo arreglas así.
4. Escribe `paginas/1-remesa.md`.
5. Pull request en tu repositorio, Actions en verde y lo fusionas.

## Bloque 2 · El oro · rama `oro`

Crea en `dbt/models/oro/` estos modelos, **con estos nombres exactos** (el portal y la jornada de Visualización los leen así):

| Modelo | Qué tiene |
|---|---|
| `dim_operario` | una fila por cada valor distinto de `operario` |
| `dim_impresora` | una fila por cada valor distinto de `impresora` |
| `dim_tipo_pieza` | una fila por cada valor distinto de `tipo_pieza` |
| `fact_trabajos` | un trabajo por fila: `pedido`, `fecha`, `operario`, `impresora`, `tipo_pieza`, `minutos`, `gramos_filamento`, `importe_eur`, `con_incidencia` |
| `pregunta_1` | ¿Qué **tipo de pieza** deja menos ingreso por hora de impresión? Una fila por `tipo_pieza`, con `tipo_pieza` en la primera columna y `ingreso_hora` (€/hora), de menor a mayor |
| `pregunta_2` | ¿Qué **operario** gasta más filamento por hora de impresión? Una fila por `operario`, con `operario` en la primera columna y `g_hora` (g/hora), de mayor a menor |
| `pregunta_3` | ¿Qué **impresora** acumula más incidencias por cada 100 horas de impresión? Una fila por `impresora`, con `impresora` en la primera columna y `incidencias_100h` (incidencias por 100 h), de mayor a menor |

En un `_oro.yml`, sus tests: en las dimensiones, `unique` y `not_null`; en el hecho, `unique` en `pedido` y `relationships` con cada dimensión.

Escribe `paginas/2-oro.md`: tu estrella y las tres respuestas. Con la remesa nueva (un 25 % más de datos), ¿siguen saliendo las mismas que en la J3? Pull request, verde, fusionas.

## Bloque 3 · Fuentes nuevas · rama `fuentes`

1. `python herramientas/sistema_simulado.py fuentes`: llegan estos ficheros a bronce y quedan declarados en `dbt/models/plata/_fuentes.yml`.

| Fichero | Qué es | Columnas |
|---|---|---|
| `bronce/materiales/materiales.csv` | un material por fila, con su rango de temperatura de boquilla (`temp_min_c`, `temp_max_c`) y su coste por kg | material, temp_min_c, temp_max_c, coste_kg_eur |
| `bronce/materiales/impresoras.csv` | qué material lleva cargado cada impresora | impresora, material |
| `bronce/eventos/lecturas_boquilla_2026-04-13.json` | El sistema de sensores exporta cada día un registro con las lecturas de temperatura de la boquilla de cada impresora, cada pocos segundos. | lectura_id, impresora, ts_lectura, temp_boquilla_c |

2. **El giro.** Los sensores van por wifi y el registro está en el **orden en que llegaron** las lecturas al servidor, no en el de la hora de lectura: algunas llegaron **tarde** y están **desordenadas**. La hora que vale es `ts_lectura`.
3. Modelos de plata: `stg_materiales`, `stg_impresoras` y `stg_eventos` (el registro lo lees con `source('bronce', 'eventos')`).
4. **Test protagonista.** Una impresora FDM gasta **entre 0,1 y 1 g de filamento por minuto**. Escribe un test singular (`tests/…sql`) que devuelva los trabajos que no cumplan esa regla (sin contar los de cantidad corregida). Tiene que ponerse rojo con la remesa sin arreglar y verde después.
5. **Pregunta 4** (`dbt/models/oro/pregunta_4.sql`): ¿Qué impresora pasa más tiempo con la boquilla **fuera del rango de temperatura de su material**? ¿Explica eso lo que viste en la pregunta 3?
6. Escribe `paginas/3-fuentes.md`. Pull request, verde, fusionas.

## Bloque 4 · El memo · rama `memo`

Escribe `paginas/memo.md`: el memo para la dirección de Filamenta Lab, con las cuatro respuestas citadas con marcas. La comprobación exige que existan `pregunta_1` a `pregunta_4`. Repasa el portal entero antes de fusionar.

---

## Lo que se entrega

- Tu repositorio en tu cuenta, con los cuatro pull requests fusionados y la última ejecución de `main` en verde.
- Tu portal publicado, con sus cuatro páginas escritas, y tu `dbt-docs`.
- La presentación oral (5 minutos): con tu portal en pantalla, el problema de calidad, tu test protagonista, las cuatro respuestas y tu recomendación.
