# Segunda iteración — Centered Battery 1.1.0

Entorno: Ambxst 1.3.14, commit `83e8462a6b03d4a7d428d5c7365e4ec03f3b63a9`,
Quickshell 0.3.2, Qt 6.12.0, Roadie 4.1.1, pantalla a escala 1.6.

| Medida, píxeles lógicos | Antes | Después |
| --- | ---: | ---: |
| Silueta con terminal | 30 × 14 | 33,6 × 16 |
| Cuerpo | 28 × 14 | 31 × 16 |
| Núcleo al 100% | 20 × 8 | 24 × 10,5 |
| Padding horizontal del núcleo | 4 | 3,5 |
| Padding vertical del núcleo | 3 | 2,75 |
| Terminal, incluyendo solapamiento | 3 × 6 | 3,6 × 7 |
| Grosor del contorno | 1,25 | 1,25 |
| Espacio preferido del widget | 36 × 36 | 36 × 36 |

El ancho visible crece exactamente 12%. La terminal queda centrada y solapada
un píxel con el cuerpo. El núcleo conserva la fórmula continua y sus extremos
redondeados. Se mantiene el color turquesa, el interior oscuro, el color de hover
y la advertencia del tema. Solo el contorno normal es un 6% más claro.

## Pruebas

- `qmllint` sin advertencias ni errores en el componente de producción.
- 17 pruebas Qt Quick aprobadas, 0 fallos: 0, 10, 25, 50, 75 y 100%, valores
  fraccionarios, límites, carga, advertencia, animación y transparencia exterior.
- `git apply --check --whitespace=error-all` correcto sobre el repositorio base.
- Comparación visual de 10, 25, 50, 75, 100% y carga en fondos claro y oscuro:
  `comparison.png`, con cada estado a tamaño normal y ampliado al doble.
- Capturas de la barra real: `bar-before.png` y `bar-after.png`; Bluetooth y
  sliders conservan sus posiciones y dimensiones, y la batería comparte su eje.
- Popup y tooltip comprobados con clic/hover reales. Carga real observada al 42%
  durante la validación. Capturas `popup.png` y `tooltip.png`.
- Se seleccionó Power Save desde el popup, se confirmó `power-saver` por D-Bus
  y se restauró Balanced mediante clic; confirmado como `balanced`.
- Rollback oficial: restauró paquete 1.0.0 y dibujo idéntico byte por byte a la
  versión anterior. Se arrancó esa generación mediante `ambxst reload`.
- Desactivación oficial: recuperó el indicador sin Centered Battery, conservando
  Roadie; la generación ya no contiene el componente gráfico del mod.
- La integración solo cambia las dos expresiones de tamaño. Se comparó el resto
  de `BatteryIndicator.qml` byte por byte con la versión funcional anterior:
  popup, tooltip, perfiles, eventos y bindings de estado están intactos.
- `BarContent.qml` y `Battery.qml` idénticos a los anteriores. El repositorio
  original sigue limpio. No se modifica la configuración de la barra ni del tema.

La batería no se descargó físicamente para recorrer los porcentajes de prueba;
estos estados se renderizan con el componente real y entradas controladas.
La orientación vertical se conserva por código, sin cambiar la configuración
horizontal del usuario. No se afirma compatibilidad con versiones de Ambxst
todavía no probadas: se conserva el rango validado y el parche con hashes completos
para que el gestor detecte conflictos al actualizar.
