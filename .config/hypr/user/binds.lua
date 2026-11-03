local mainMod = "SUPER"

-- =========================
-- Unbind Ambxst conflicts
-- =========================

local custom_binds = {
    mainMod .. " + Return",
    mainMod .. " + E",
    mainMod .. " + T",
    mainMod .. " + F",
    mainMod .. " + Q",
    mainMod .. " + left",
    mainMod .. " + right",
    mainMod .. " + up",
    mainMod .. " + down",
    mainMod .. " + mouse:272",
    mainMod .. " + mouse:273",
    mainMod .. " + SHIFT + B",
    mainMod .. " + SHIFT + S",
    mainMod .. " + ALT + Down",
    mainMod .. " + ALT + j",
    mainMod .. " + ALT + Up",
    mainMod .. " + ALT + k",
    "XF86AudioRaiseVolume",
    "XF86AudioLowerVolume",
    "XF86AudioMute",
    "XF86AudioMicMute",
    "XF86MonBrightnessUp",
    "XF86MonBrightnessDown",
    "XF86AudioNext",
    "XF86AudioPrev",
    "XF86AudioPlay",
    "XF86AudioPause",
}

for _, bind in ipairs(custom_binds) do
    hl.unbind(bind)
end

-- Fn+F6 de la laptop manda Super+Shift+S (con Shift derecho, pero Hyprland no
-- distingue cuál). Lo pongo a tomar screenshot igual que Super+S en vez de
-- abrir las herramientas de Ambxst, que siguen en el botón de la barra.
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("ambxst run screenshot"))

-- Ambxst asignaba dos acciones a esta combinación. Dejo solo la barra.
-- Para reiniciar la shell ejecuto `ambxst reload` explícitamente.
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("ambxst toggle bar"))

-- El generador de Ambxst usa exec_cmd("resizeactive ...") en estos cuatro
-- atajos. Los sustituyo aquí sin editar su archivo generado.
for _, key in ipairs({ "Down", "j" }) do
    hl.bind(mainMod .. " + ALT + " .. key,
        hl.dsp.window.resize({ x = 0, y = 50, relative = true }))
end
for _, key in ipairs({ "Up", "k" }) do
    hl.bind(mainMod .. " + ALT + " .. key,
        hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
end

for i = 1, 10 do
    local key = i % 10
    hl.unbind(mainMod .. " + " .. key)
    hl.unbind(mainMod .. " + SHIFT + " .. key)
end


-- =========================
-- Applications
-- =========================

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"))


-- =========================
-- Windows
-- =========================

hl.bind(
    mainMod .. " + T",
    hl.dsp.window.float({ action = "toggle" })
)

hl.bind(
    mainMod .. " + Q",
    hl.dsp.window.close()
)

hl.bind(
    mainMod .. " + F",
    hl.dsp.window.fullscreen()
)


-- =========================
-- Focus
-- =========================

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))


-- =========================
-- Workspaces 1-10
-- =========================

for i = 1, 10 do
    local key = i % 10

    hl.bind(
        mainMod .. " + " .. key,
        hl.dsp.focus({ workspace = i })
    )

    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i })
    )
end


-- =========================
-- Mouse
-- =========================

hl.bind(
    mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)

hl.bind(
    mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)


-- =========================
-- Audio
-- =========================

hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true }
)

hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true }
)

hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true }
)

hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true }
)


-- =========================
-- Brightness
-- =========================

-- brightnessctl con la curva -e4, y luego le pido a Ambxst que vuelva a leer
-- el brillo (`brightness pull`) para que salga el OSD. Ambxst no se entera
-- de los cambios que hace brightnessctl por su cuenta.
local function brightness(step)
    return hl.dsp.exec_cmd(
        [[sh -c 'brightnessctl -q -e4 -n2 set ]] .. step .. [[ && qs ipc --pid "$(cat "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ambxst-qs.pid")" call brightness pull ""']]
    )
end

hl.bind("XF86MonBrightnessUp", brightness("5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", brightness("5%-"), { locked = true, repeating = true })


-- =========================
-- Multimedia
-- =========================

hl.bind(
    "XF86AudioNext",
    hl.dsp.exec_cmd("playerctl next"),
    { locked = true }
)

hl.bind(
    "XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous"),
    { locked = true }
)

hl.bind(
    "XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)

hl.bind(
    "XF86AudioPause",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)


-- =========================
-- Teclas de la Zephyrus G16 (GA605KP)
-- =========================
-- Lo que manda cada tecla lo saqué capturando /dev/input. Las que no salen
-- aquí ya funcionan solas o tienen bind arriba:
--   Fn+F1 mute, Fn+F7/F8 brillo, mic, volumen y media: arriba
--   Fn+F2/F3 luz del teclado: la maneja el firmware (asus::kbd_backlight)
--   Fn+F6 manda Super+Shift+S: abre las herramientas de Ambxst (screenshot)
--   Fn+F9 manda Super+P: proyectar pantalla, sin bind con una sola pantalla

local function notify(title, body)
    return [[notify-send -a "ROG" -t 1500 "]] .. title .. [[" "]] .. body .. [["]]
end

-- Tecla ROG (KEY_PROG1): abre ROG Control Center. Si ya está en el tray
-- solo muestra su ventana, no abre otra instancia.
hl.bind("XF86Launch1", hl.dsp.exec_cmd("rog-control-center"))

-- Fn+F4 Aura (KEY_PROG3): siguiente efecto de la luz del teclado.
hl.bind("XF86Launch3", hl.dsp.exec_cmd("asusctl aura effect --next-mode"))

-- Fn+F5 ventilador (KEY_PROG4): siguiente perfil Quiet / Balanced / Performance
-- y lo muestra en el OSD de Ambxst (mod osd-fix, `qs ipc call rog announce`).
hl.bind("XF86Launch4", hl.dsp.exec_cmd(
    [[sh -c 'asusctl profile next >/dev/null && qs ipc --pid "$(cat "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ambxst-qs.pid")" call rog announce']]
))

-- Fn+F10 touchpad (KEY_F21): lo apaga y lo prende. Al hacer reload de
-- Hyprland vuelve a quedar prendido.
local touchpad = "asuf1209:00-2808:0219-touchpad"
local touchpad_on = true
hl.bind("XF86TouchpadToggle", function()
    touchpad_on = not touchpad_on
    hl.device({ name = touchpad, enabled = touchpad_on })
    hl.exec_cmd(notify("Touchpad", touchpad_on and "Prendido" or "Apagado"))
end)
