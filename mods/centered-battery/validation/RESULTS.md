# Primera iteración 1.0.0 — validación histórica

La validación actual de 1.2.0 está en [iteration3/RESULTS.md](iteration3/RESULTS.md).

## Entorno

- Repositorio base: `/home/nosfeik/.local/src/ambxst`.
- Ambxst 1.3.14, commit `83e8462a6b03d4a7d428d5c7365e4ec03f3b63a9`.
- Quickshell 0.3.2, Qt 6.12.0; Hyprland, pantalla eDP-1 a escala 1.6.
- Roadie 4.1.1 habilitado antes y después de la instalación.
- Referencia visual: captura «04 — Núcleo Centrado» enviada durante la implementación.

## Resultados

| Comprobación | Resultado |
| --- | --- |
| Manifest y operaciones | Aceptados por el gestor oficial; mod válido y compatible |
| Parche | `git apply --check --whitespace=error-all` correcto sobre la base |
| Composición con Roadie | `ambxst mods check-compatibility` devuelve `composes: true` |
| Sintaxis del componente | `qmllint` sin advertencias ni errores |
| Pruebas Qt Quick | 17 aprobadas, 0 fallos; véase `qml-tests.txt` |
| Estados | 0, 10, 25, 50, 75, 100, 37.25 y 0.5%; también límites inválidos |
| Carga | Rayo reactivo, dimensiones y relleno sin cambios al activarlo |
| Advertencia | Por debajo de 10%, cambio reactivo al color del tema; 10% turquesa |
| Animación | Transición intermedia y final verificadas; desactivación inmediata |
| Fondo exterior | Prueba de píxeles: el fondo del padre se conserva fuera de la silueta |
| Instalación | Carpeta instalada mediante `ambxst mods install` |
| Activar/desactivar | Activación, desactivación, actualización y reactivación completadas |
| Restauración | La generación deshabilitada recupera byte por byte el indicador anterior con Roadie y elimina el componente añadido |
| Arranque real | Generación final cargada y estable después de la ventana de salud; no requiere reinicio |
| Batería real | Carga conectada, porcentaje observado subiendo de 24 a 33%; relleno y rayo visibles |
| Tooltip | Capturado mostrando `Battery: 31% (Charging)` |
| Popup | Abierto mediante clic real en la batería; porcentaje, estado, tiempo y tres perfiles visibles |
| Perfiles | Clic en Power Save cambia D-Bus a `power-saver`; clic en Balanced restaura `balanced` |
| Duplicación | Un solo gráfico dentro de cada instancia original; sin indicador añadido a BarContent |
| Conservación | BarContent y Battery idénticos a la generación con Roadie sin este mod; MouseArea, tooltip y popup íntegros |
| Repositorio original | `git status --porcelain` vacío después de las pruebas |

El gestor impidió inicialmente una actualización mientras esperaba el arranque de
una generación pendiente. Se completó ese arranque y se repitió la actualización
con éxito, sin editar su estado ni eludir sus comprobaciones.

El ajuste final conserva un núcleo de ancho continuo con ambos extremos redondeados,
contorno redondeado de 30 × 14 y turquesa más cercano a la referencia. El ZIP se
construye con los mismos archivos de implementación que la generación activa.

## Evidencia local

- `states.png`: estados en fondo claro y oscuro, a tamaño normal y doble.
- `bar-before.png` / `bar-after.png`: barra real antes y después.
- `tooltip.png`, `popup.png`, `profile-click.png`: interacciones reales.
- `profiles.txt`: lectura D-Bus antes, tras ahorro y después de restaurar Balanced.
- `qml-tests.txt`: salida completa de Qt Quick Test.

El ZIP incluye la galería, este informe y los resultados QML. Las capturas de la
sesión y la copia inicial de `mods.json` permanecen únicamente en la carpeta local
de trabajo. Esa copia es evidencia, no un archivo que deba restaurarse a mano:
el gestor puede depurar generaciones antiguas. Usa los comandos del README.

## Límites

- Los estados de descarga extrema y sin batería se comprueban mediante entradas
  de prueba y conservación del código; no se descargó físicamente el equipo.
- La prueba en la sesión real usa la barra horizontal superior. El mod conserva
  los layouts horizontal y vertical y adapta el tamaño disponible; no se cambió
  la orientación de la configuración del usuario para esta prueba.
- Se verificaron fuente, composición, instalación por carpeta y el ZIP mediante
  inspección de entradas/CRC. La importación del ZIP desde el diálogo de Settings
  no se automatizó; usa el formato de archivo admitido por ese mismo gestor.
- El registro de la sesión contiene avisos ajenos a la batería en CompactPlayer,
  SysTray, Pomodoro y recursos ausentes. No aparecen errores de BatteryIndicator
  ni de CenteredBatteryGraphic. Esos otros componentes no se modificaron.
- No se declara compatibilidad con versiones posteriores a Ambxst 1.3.14.
