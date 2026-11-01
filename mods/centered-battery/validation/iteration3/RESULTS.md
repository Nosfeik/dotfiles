# Tercera iteración — Centered Battery 1.2.0

Probado el 2026-11-01 en Ambxst 1.3.14
(`83e8462a6b03d4a7d428d5c7365e4ec03f3b63a9`), Quickshell 0.3.2, Qt 6.12.0,
Roadie 4.1.1 y pantalla eDP-1 a escala 1.6.

## Diseño final y referencia

La imagen enviada durante esta iteración muestra una cápsula negra horizontal,
del mismo alto que Bluetooth y sliders, con cuerpo claro redondeado y núcleo
turquesa. Se amplió el ancho de la cápsula para conservar esa silueta horizontal
al aumentar sustancialmente el grosor del cuerpo.

| Medida lógica | Versión 1.1.0 | Versión 1.2.0 |
| --- | ---: | ---: |
| Área exterior | 36 × 36, transparente | 74 × 36, cápsula temática |
| Dibujo con terminal | 33,6 × 16 | 56,6 × 26 |
| Cuerpo | 31 × 16 | 54 × 26 |
| Núcleo completo | 24 × 10,5 | 46 × 18 |
| Contorno | 1,25 | 1,5 |
| Terminal | 3,6 × 7 | 3,6 × 8 |

El cuerpo gana 10 píxeles de altura (+62,5%). Ocupa el 72,2% de la cápsula,
y el núcleo el 81,8% del alto interior libre. La cápsula tiene 5 píxeles de
padding vertical y 8,7 horizontal alrededor del dibujo. La terminal solapa un
píxel con el cuerpo. No se añade sombra. La prioridad de grosor del texto se
mantiene; no se pretende copiar a escala exacta todos los píxeles de la imagen.

## Pruebas completadas

- `qmllint` sin errores ni advertencias en el componente de producción.
- 17 pruebas Qt Quick aprobadas, 0 fallos: relleno continuo en 0, 10, 25, 50,
  75 y 100%; fracciones, límites, animación, carga, advertencia y transparencia
  fuera del dibujo. La cápsula se implementa en el contenedor existente.
- Galería con el componente final a porcentajes fijos, en fondos claros y oscuros:
  `states.png`. El fondo de esa galería es ilustrativo; la barra real usa StyledRect.
- `git apply --check --whitespace=error-all` correcto sobre la base instalada.
- Gestor oficial: paquete válido/compatible y `check-compatibility` con composición
  correcta junto con Roadie. Arranque real completado y estable.
- Captura final `bar-after.png`: batería centrada, cápsula de la misma altura que
  Bluetooth y sliders. `bar-before.png` conserva la versión anterior; los recortes
  tienen diferente anchura para incluir el espacio nuevo.
- Batería real cargando al 59% durante la captura final. No hay texto permanente
  de porcentaje en la barra; aparece en tooltip y popup como antes.
- Popup abierto mediante clic real. Tooltip capturado con hover: `popup.png` y
  `tooltip.png`.
- Se seleccionó Power Save mediante clic y se confirmó `power-saver` por D-Bus;
  después se seleccionó Balanced y se confirmó la restauración de `balanced`.
  Registro en `profiles.txt`.
- Rollback mediante el gestor: regresó a 1.1.0; el gráfico recuperado coincidió
  byte por byte con la copia previa. Se arrancó esa generación y posteriormente
  se actualizó de nuevo a la versión final 1.2.0.
- Comparación de fuentes: `BarContent.qml` y `Battery.qml` idénticos a los previos;
  MouseArea, tooltip, popup y perfiles idénticos desde el bloque de interacción
  hasta el final del archivo. No se agrega un indicador a BarContent.
- El repositorio original continúa limpio. El único cambio de distribución es
  el ancho preferido de BatteryIndicator. Su alto sigue siendo 36.

El registro de la sesión conserva un aviso de `GlobalStates` en CompactPlayer,
ajeno a este mod. No aparecen errores de BatteryIndicator ni CenteredBatteryGraphic.

## Límites y recuperación

Se comprobó la barra horizontal real; en una barra vertical estrecha el dibujo
se reduce proporcionalmente para evitar recortes. Los porcentajes extremos se
validan con entradas de prueba, sin descargar físicamente el equipo. El tema
global, la altura de la barra y las dimensiones de los widgets vecinos no cambian.

La versión final queda habilitada. Usa `ambxst mods rollback` y `ambxst reload`
para volver a la generación anterior. También se conserva el ZIP 1.1.0. El README
explica desactivación, reinstalación y recuperación si el gestor depura generaciones.
No se deben restaurar a mano las copias de estado guardadas como evidencia.
