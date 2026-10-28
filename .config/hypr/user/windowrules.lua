-- =========================
-- No initial focus
-- =========================

local telegram = [[^(org\.telegram\.desktop|telegram-desktop|TelegramDesktop)$]]
local discord = [[^(discord|discord-canary|discord-ptb|Discord)$]]
local rog = [[^(rog-control-center|RogControlCenter)$]]

local no_focus_classes = {
    telegram,
    [[^(elecwhat)$]],
    discord,
    rog,
}

for _, class in ipairs(no_focus_classes) do
    hl.window_rule({
        match = { class = class, modal = false },
        no_initial_focus = true,
    })
end


-- =========================
-- Floating applications, sized in logical monitor coordinates
-- =========================

-- At scale 1.6, a 2560x1600 display is 1600x1000 logical pixels.
-- Fixed 1800x1200 / 2200x1400 sizes used to overflow that display.
-- Expressions adapt to the monitor where each window opens.
local app_rules = {
    { class = [[^(elecwhat)$]], width = 0.78, height = 0.80 },
    { class = telegram, width = 0.78, height = 0.80 },
    { class = discord, width = 0.78, height = 0.80 },
    { class = [[^(org\.gnome\.Nautilus|nautilus|thunar|Thunar|org\.kde\.dolphin)$]], width = 0.70, height = 0.72 },
    { class = rog, width = 0.74, height = 0.78 },
    { class = [[^(org\.gnome\.Settings|gnome-control-center|systemsettings|org\.kde\.systemsettings)$]], width = 0.74, height = 0.78 },
    { class = [[^(pavucontrol|org\.pulseaudio\.pavucontrol|pwvucontrol|com\.saivert\.pwvucontrol)$]], width = 0.54, height = 0.62 },
    { class = [[^(nm-connection-editor|nm-applet)$]], width = 0.52, height = 0.58 },
    { class = [[^(blueman-manager|blueman-adapters|blueberry\.py)$]], width = 0.42, height = 0.48 },
    { class = [[^(transmission-gtk|com\.transmissionbt\.Transmission)$]], width = 0.68, height = 0.72 },
    { class = [[^(org\.gnome\.FileRoller|file-roller|org\.kde\.ark)$]], width = 0.62, height = 0.68 },
}

for _, rule in ipairs(app_rules) do
    hl.window_rule({
        match = { class = rule.class, modal = false },
        float = true,
        center = true,
        size = { "monitor_w * " .. rule.width, "monitor_h * " .. rule.height },
    })
end

-- Preserve natural sizes for small tools and authentication prompts.
local natural_size_classes = {
    [[^(Rofi|rofi|eww)$]],
    [[^(org\.gnome\.Calculator|gnome-calculator|qalculate-gtk|org\.kde\.kcalc)$]],
    [[^(org\.gnome\.design\.Palette|org\.gnome\.Characters|org\.gnome\.font-viewer)$]],
    [[^(org\.kde\.polkit-kde-authentication-agent-1|polkit-gnome-authentication-agent-1|hyprpolkitagent)$]],
    [[^(pinentry|pinentry-.*|gcr-prompter|gcr-viewer)$]],
    [[^(zenity|org\.gnome\.Zenity|yad|org\.gnome\.FileRoller\.Progress)$]],
}

for _, class in ipairs(natural_size_classes) do
    hl.window_rule({
        match = { class = class },
        float = true,
        center = true,
    })
end


-- =========================
-- File pickers and dialogs (evaluated after main application sizes)
-- =========================

local file_picker_matches = {
    { class = [[^(xdg-desktop-portal(-gtk|-gnome|-kde|-hyprland)?|org\.freedesktop\.impl\.portal\.desktop\.(gtk|gnome|kde))$]] },
    { title = [[^(Open File(s)?|Save File|Save As|Select (a )?(File|Folder)|Choose (a )?(File|Folder)|File (Upload|Download))(\.\.\.|…)?$]] },
    { title = [[^(Abrir archivo(s)?|Guardar archivo|Guardar como|Seleccionar (un )?(archivo|carpeta)|Elegir (un )?(archivo|carpeta))(\.\.\.|…)?$]] },
}

for _, match in ipairs(file_picker_matches) do
    hl.window_rule({
        match = match,
        float = true,
        center = true,
        no_initial_focus = false,
        size = { "monitor_w * 0.65", "monitor_h * 0.70" },
    })
end

hl.window_rule({
    match = { modal = true },
    float = true,
    center = true,
    no_initial_focus = false,
})

hl.window_rule({
    match = { title = [[^(Color Picker|Selector de color|Network)$]] },
    float = true,
    center = true,
})

hl.window_rule({
    match = { title = [[^(web\.whatsapp\.com_/)$]] },
    float = true,
    center = true,
    size = { "monitor_w * 0.78", "monitor_h * 0.80" },
})

hl.window_rule({
    match = {
        class = [[^(firefox|org\.mozilla\.firefox|chromium|Brave-browser|brave-origin-nightly|brave-browser|brave|google-chrome)$]],
        title = [[^(Picture-in-Picture|Picture in picture|Picture-in-picture|Imagen en imagen)$]],
    },
    float = true,
    size = { "monitor_w * 0.28", "monitor_h * 0.27" },
    move = { "monitor_w - window_w - 24", "monitor_h - window_h - 24" },
    keep_aspect_ratio = true,
})

-- Bound ordinary floating windows, including unknown dialog classes.
-- Fullscreen/maximized windows and tiled windows retain their own geometry.
-- Re-evaluation also prevents an oversized client resize after startup.
hl.window_rule({
    match = { float = true, fullscreen = false },
    max_size = { "monitor_w * 0.90", "monitor_h * 0.86" },
})


-- =========================
-- Workspace assignments
-- =========================

local workspace_rules = {
    { class = [[^(code)$]], workspace = "3" },
    { class = telegram, workspace = "7" },
    { class = [[^(Vmware|vmware)$]], workspace = "4" },
    { class = [[^(chromium)$]], workspace = "2" },
    { class = [[^(kitty)$]], workspace = "1" },
    { class = [[^(Brave-browser|brave-origin-nightly|brave-browser|brave)$]], workspace = "2" },
    { class = [[^(firefox)$]], workspace = "2" },
    { class = [[^(obsidian)$]], workspace = "4" },
    { class = discord, workspace = "6" },
    { class = [[^(elecwhat)$]], workspace = "8 silent" },
    { class = rog, workspace = "9 silent" },
    { class = [[^(Spotify|spotify)$]], workspace = "5" },
}

for _, rule in ipairs(workspace_rules) do
    hl.window_rule({
        match = { class = rule.class, modal = false },
        workspace = rule.workspace,
    })
end
