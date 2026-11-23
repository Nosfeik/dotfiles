-- =========================
-- Animations
-- =========================
-- Sobrescribe las animaciones que genera axctl en ~/.local/share/ambxst/hyprland.lua.
-- Speed va en décimas de segundo (4 = 400ms).

hl.curve("emphasized", { type = "bezier", points = { {0.05, 0.7}, {0.1, 1.0} } })
hl.curve("standard",   { type = "bezier", points = { {0.2, 0.0}, {0.0, 1.0} } })
hl.curve("accel",      { type = "bezier", points = { {0.3, 0.0}, {0.8, 0.15} } })

-- Ventanas: entran rápido y frenan suave, salen acelerando y más cortas
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4,   bezier = "emphasized", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2,   bezier = "accel",      style = "popin 87%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3.5, bezier = "emphasized" })

hl.animation({ leaf = "fadeIn",     enabled = true, speed = 3, bezier = "emphasized" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 2, bezier = "accel" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "fadeDim",    enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "border",     enabled = true, speed = 4, bezier = "standard" })

-- Workspaces: slide completo para que siga el gesto de 3 dedos
hl.animation({ leaf = "workspaces",        enabled = true, speed = 4, bezier = "emphasized", style = "slide" })
hl.animation({ leaf = "specialWorkspace",  enabled = true, speed = 4, bezier = "emphasized", style = "slidevert" })

-- Layers que no son de quickshell (Ambxst ya les pone no_anim)
hl.animation({ leaf = "layersIn",  enabled = true, speed = 3, bezier = "emphasized", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "accel",      style = "fade" })

hl.animation({ leaf = "zoomFactor", enabled = true, speed = 4, bezier = "standard" })
