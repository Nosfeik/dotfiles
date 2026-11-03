# Centered Battery

Mod para [Ambxst](https://github.com/Axenide/Ambxst) que cambia el indicador de batería de la barra. El que trae por defecto es un anillo circular y la verdad no se me hacía muy claro, entonces lo cambié por una batería compacta con el porcentaje al lado, usando los mismos colores del tema para que combine con los demás widgets.

![Barra](screenshots/bar.png)

## Qué hace

La batería se llena según el porcentaje real y cambia de color dependiendo del nivel: con el color primario del tema arriba de 20%, amarillo abajo de 20% y rojo abajo de 10%, donde además parpadea tantito. Cuando está cargando sale un rayo y un brillo que recorre el relleno. Al pasar el mouse se ilumina la cápsula y cuando abres el popup se pone del color primario, igual que el indicador original.

![Estados](screenshots/states.png)

El ancho de la cápsula está calculado para "100%", entonces no se mueve la barra cuando el número cambia de dígitos. En barra vertical nada más se muestra la batería sin el porcentaje.

El popup, el tooltip y los perfiles de energía no los toqué, se quedan como vienen en Ambxst. Si la máquina no tiene batería se sigue mostrando el icono del perfil de energía.

## Compatibilidad

Lo probé en Ambxst **1.3.14** (`83e8462a`). El manifest está limitado a `>=1.3.14 <1.3.15` porque el patch modifica `modules/bar/BatteryIndicator.qml` y con otra versión puede no aplicar. Es compatible con Roadie.

## Instalar

```sh
git clone https://github.com/Nosfeik/ambxst-centered-battery.git
ambxst mods install ./ambxst-centered-battery
ambxst mods enable local.centered-battery
ambxst reload
```

También se puede importar la carpeta desde **Settings → Mods**.

Para regresar a la versión anterior:

```sh
ambxst mods rollback
ambxst reload
```

## Estructura

- `payload/modules/bar/CenteredBatteryPill.qml`: el componente nuevo, nada más dibuja. El estado y los colores se los pasa el indicador.
- `patches/centered-battery.patch`: cambia el bloque visual y el ancho de `BatteryIndicator.qml` para usar el componente.

Los colores salen de `Colors.primary`, `Colors.yellow`, `Colors.red`, `Colors.overBackground` y `Colors.background`, entonces si cambias de tema la batería se adapta sola.
