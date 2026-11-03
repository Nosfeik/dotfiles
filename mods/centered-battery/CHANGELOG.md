# 1.3.1

- Rayo más ancho, con relleno claro y dentro del área interior; ya no corta el borde de la batería y se lee sobre el relleno y la pista vacía.
- Quita el warning `Unable to assign [undefined] to double` del hover (`radius: buttonBg.radius`).
- Tests nuevos para `CenteredBatteryPill` en `tests/tst_pill.qml`; se quita `tst_graphic.qml`, que apuntaba al componente viejo.

# 1.3.0

- Nuevo diseño: batería compacta con porcentaje al lado.
- Colores del tema en lugar de colores fijos (primario, amarillo abajo de 20%, rojo abajo de 10%).
- Parpadeo en nivel crítico, rayo y brillo al cargar.
- La cápsula se pone del color primario con el popup abierto y se ilumina con hover.
- Ancho fijo calculado para "100%" para que la barra no se mueva.

# 1.2.3

- Altura del cuerpo de 19 píxeles; núcleo de 11, terminal y rayo recentrados.
- Largo de 56,6 y cápsula de 74 × 36 intactos.

# 1.2.2

- Reduce otros 2 píxeles: cuerpo de 22 y núcleo de 14 de alto.
- Largo de 56,6 y cápsula de 74 × 36 intactos.

# 1.2.1

- Reduce la altura interior de 26 a 24 y el núcleo de 18 a 16.
- Conserva el largo de 56,6 y la cápsula de 74 × 36; terminal y rayo recentrados.

# 1.2.0

- Cápsula temática de 74 × 36: misma altura que los widgets vecinos, sin sombra.
- Dibujo de 56,6 × 26; cuerpo de 54 × 26 con contorno uniforme de 1,5.
- Núcleo de 46 × 18, aproximadamente el 82% de la altura interior.
- Proporción horizontal adaptada a la referencia enviada; terminal pequeña y centrada.
- Conserva lógica de batería, colores, tooltip, clics, popup, perfiles y animaciones.
- Captura real, pruebas de estados y rollback oficial a 1.1.0.

# 1.1.0

- Silueta de 33,6 × 16 en lugar de 30 × 14, manteniendo el espacio original de la barra.
- Menor padding y núcleo de 24 × 10,5, con el mismo porcentaje continuo y turquesa.
- Contorno normal un 6% más claro, con grosor intacto; terminal de 3,6 × 7.
- Popup, tooltip, perfiles, lecturas y animaciones sin cambios funcionales.
- Comparación antes/después y validación de rollback, desactivación y perfiles.
