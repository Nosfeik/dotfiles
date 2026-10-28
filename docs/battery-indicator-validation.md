# Battery Indicator — validación

Comprobado el 2026-10-21 en Ambxst 1.3.7, base
`9a9026a4e6ac5431a68fa6928fd1af32918b98e3`.
Mod `local.battery-indicator` 0.1.0, instalado y actualizado con Mods;
generación final `20261021T235942Z-f4526813`.

- Parser oficial del manifiesto, overlays y hash: correctos. Solo se reemplaza
  BatteryIndicator. Un original cambiado rechaza la validación.
- QML parseado con qmlformat y cargado en la shell real; Python parseado.
- 42 comprobaciones de estado, umbrales, datos desconocidos, tooltip y límite.
- D-Bus privado: cambio de límite, dato inválido, pérdida y retorno del servicio,
  silencio en reposo y salida por EOF. No se accedió a asusd desde esa prueba.
- 16 fixtures × 2 paletas × 3 escalas (1, 1.6, 2), con comprobación numérica del
  ancho del fill. No se modificó hardware ni se inyectaron fixtures en producción.
- UPower real al capturar: 66%, Charging, OnBattery=false. asusd: límite 80.
  Tooltip concordante; sin check mientras carga. El caso de límite alcanzado se
  validó con fixtures, no forzando la batería real.
- Pantalla 2560×1600, escala 1.6. Espacio del control 36×36; reserva horizontal
  intacta de 40 px lógicos. Barra vertical probada (reserva izquierda 40 px),
  sin desbordamiento; bar.json restaurado byte por byte a su posición superior.
- Hover correcto. Envío de botones izquierdo, middle y derecho sin popup de
  batería; el componente no contiene MouseArea/TapHandler ni acciones de energía.
- Una instancia de Ambxst después de la ventana de salud de ocho segundos.
  Un puente GJS hijo, aproximadamente 29 MiB RSS y 0.0% CPU observado en reposo.
  Los puentes anteriores terminaron al recargar. Sin procesos de polling sysfs.
- Sin avisos atribuibles al mod en el log final. Quedan avisos nativos de
  CompactPlayer, Pomodoro, archivos opcionales e imágenes. Durante la sesión se
  observaron también avisos del reproductor de wallpapers, fuera de este cambio.
- Tras reload, Ambxst produjo su error transitorio conocido de comillas en
  colores Hyprland. `hyprctl reload` lo limpió; `hyprctl configerrors` vacío.
  No se editaron los archivos generados para corregirlo.
- Battery.qml coincide byte por byte con upstream; BarContent no cambia respecto
  de la generación previa. Source base limpio, Pentest sin cambios. `git diff
  --check` correcto. No se añadieron secretos, material VPN ni credenciales.

Capturas: [barra anterior](assets/battery-indicator/bar-before.png),
[barra instalada](assets/battery-indicator/bar-real.png),
[tooltip real](assets/battery-indicator/tooltip-real.png),
[vertical](assets/battery-indicator/bar-vertical.png),
[fixtures oscuros](assets/battery-indicator/dark-1.6.png),
[fixtures claros](assets/battery-indicator/light-1.6.png).
Las hojas muestran tamaño normal y un detalle ampliado 2×.

Limitaciones deliberadas: no se deduce límite en equipos con múltiples baterías,
estados Unknown/Discharging ni datos incompletos. La notificación conserva la
política nativa, incluida su deduplicación y comportamiento al reiniciar la shell.
El fallback sysfs tiene hasta 60 s de latencia; D-Bus es reactivo. El paquete
queda limitado a Ambxst 1.3.7 y al hash revisado hasta auditar una actualización.

Instalación, fuentes y rollback: [README del mod](../mods/battery-indicator/README.md).
