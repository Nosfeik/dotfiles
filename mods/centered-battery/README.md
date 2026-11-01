# Centered Battery 1.2.3

Mod para Ambxst **1.3.14**, API de Mods 1, probado sobre
`83e8462a6b03d4a7d428d5c7365e4ec03f3b63a9`, con Quickshell 0.3.2 / Qt 6.12 y Roadie 4.1.1.

Tercera iteración del concepto **04 — Núcleo Centrado**: cuerpo grueso, núcleo
turquesa continuo y una cápsula exterior con el fondo nativo de los widgets.
La referencia de esta iteración sustituye el requisito anterior de fondo transparente.

## Medidas

| Elemento | 1.1.0 | 1.2.3 |
| --- | --- | --- |
| Área / cápsula exterior | 36 × 36, transparente | 74 × 36, fondo temático |
| Dibujo con terminal | 33,6 × 16 | 56,6 × 19 |
| Cuerpo | 31 × 16 | 54 × 19 |
| Núcleo completo | 24 × 10,5 | 46 × 11 |
| Contorno | 1,25 | 1,5 |
| Terminal | 3,6 × 7 | 3,6 × 8 |

Todas las medidas son píxeles lógicos. La altura del cuerpo es 52,8% de la cápsula;
el núcleo ocupa 73,3% de los 15 píxeles interiores libres tras el contorno.
El padding exterior es 8,7 horizontal y 8,5 vertical. La terminal solapa un píxel
con el cuerpo y está centrada. La cápsula usa radio 18 y no añade sombra.

La altura de la barra y de los vecinos no cambia. Se reserva más ancho únicamente
para esta batería, para reproducir la cápsula horizontal de la imagen sin comprimir
el dibujo grueso. La barra redistribuye su grupo con el layout existente.
En una barra vertical estrecha, el dibujo se reduce proporcionalmente para evitar
recortes, conservando la orientación horizontal.

## Instalar, actualizar y activar

En **Settings → Mods**, importa `centered-battery-1.2.3.zip` o esta carpeta,
habilita **Centered Battery** y reinicia Ambxst. Si ya está instalado desde esta
carpeta, usa la actualización del paquete.

```sh
ambxst mods install /home/nosfeik/Dev/dotfiles/mods/centered-battery
ambxst mods enable local.centered-battery
ambxst reload
```

Para actualizar una instalación existente desde esta carpeta:

```sh
ambxst mods update local.centered-battery
ambxst reload
```

El gestor exige arrancar una generación pendiente antes de aceptar otra actualización.
No hay dependencias ni comandos nuevos. Se mantiene el conflicto con el antiguo
`local.battery-indicator`, que modifica el mismo componente. Roadie sigue siendo compatible.

## Integración conservada

- El overlay añade solamente `modules/bar/CenteredBatteryGraphic.qml`.
- El parche modifica el bloque visual y el ancho preferido de `BatteryIndicator.qml`.
  La cápsula usa el `StyledRect` existente, variante `bg`, sin borde ni sombra propios.
- `MouseArea`, `StyledToolTip`, popup y perfiles de energía se conservan literalmente.
- `BarContent.qml`, el servicio `Battery`, los demás widgets y los archivos de tema
  no se modifican. Se mantiene un indicador por layout y pantalla, sin duplicaciones.
- `Battery.percentage` continúa controlando el ancho real: `46 * porcentaje / 100`.
  No se redondea ni se impone un segmento mínimo. El cero queda vacío.
- `Battery.isCharging` controla el mismo rayo. Sin batería se conserva el icono
  y acceso a perfiles; el ancho vuelve a 36.
- Núcleo turquesa, interior oscuro y colores del contorno se conservan respecto a
  1.1.0. Por debajo de 10%, se usa `Colors.red`; las alertas nativas no cambian.
- El fondo exterior sigue el tema con la misma variante que Bluetooth y sliders;
  en la configuración actual es negro. Hover/popup aclaran el contorno de la batería.
- `Config.animDuration` sigue controlando la animación. No hay procesos, polling,
  temporizadores ni efectos adicionales en el componente de producción.

Quickshell descubre el componente añadido en su módulo sin `qmldir`. El gestor
aplica el parche a una generación separada. Roadie transforma el popup base en
`BarPopout`; ambas variantes quedan intactas porque el parche no modifica el popup.

## Revertir, desactivar y recuperar

Para volver a la generación anterior:

```sh
ambxst mods rollback
ambxst reload
```

Se verificó el regreso a 1.1.0 mediante el gestor. El ZIP de esa versión se conserva
junto al nuevo. Si el gestor ya depuró la generación anterior, deshabilita y elimina
Centered Battery, importa `centered-battery-1.1.0.zip` y vuelve a habilitarlo.

Para recuperar el indicador original conservando Roadie:

```sh
ambxst mods disable local.centered-battery
ambxst reload
# Tras arrancar esa generación, eliminación opcional:
ambxst mods remove local.centered-battery
```

Si no abre la interfaz, el gestor dispone de recuperación automática durante los
primeros ocho segundos. También puedes usar el rollback desde terminal. Para
seleccionar la base sin mods: `ambxst mods base` y `ambxst reload`. Alternativamente,
detén Ambxst con `ambxst quit` y ejecuta `AMBXST_MODS_DISABLED=1 ambxst`.
No sobrescribas fuentes ni generaciones; las copias de validación son solo evidencia.

## Validación

```sh
/usr/lib/qt6/bin/qmllint payload/modules/bar/CenteredBatteryGraphic.qml
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software /usr/lib/qt6/bin/qmltestrunner -input tests
QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qml tests/ThickPreview.qml
ambxst mods check-compatibility /home/nosfeik/.local/src/ambxst
```

La galería actual está en `validation/iteration3/states.png`; los resultados y las
capturas reales están en `validation/iteration3/RESULTS.md`. `Preview.qml`,
`Compare.qml`, `CompareBar.qml` y sus fixtures conservan las comparaciones históricas
anteriores. No se cargan en la barra ni forman parte de las operaciones del manifest.

Se conserva el rango validado de Ambxst; el parche incluye hashes completos para
la composición y detección de conflictos. No se promete compatibilidad con versiones
futuras sin probarlas ni se activa el bypass del gestor.

Formato basado en la [documentación oficial de Mods](https://github.com/Axenide/Ambxst/blob/main/docs/mods/README.md)
y en el código y esquema de la versión instalada.
