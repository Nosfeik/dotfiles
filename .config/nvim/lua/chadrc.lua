-- Custom theme; kept outside NvChad's built-in theme-name type list.
local M = {}
M.base46 = {
  theme = "green_black",
  transparency = false,
  theme_toggle = { "green_black", "xerux_black" },
  hl_override = {
    Normal = { bg = "#101010", fg = "#a8d5bf" },
    NormalNC = { bg = "#101010" },
    NormalFloat = { bg = "#181818" },
    CursorLine = { bg = "#202020" },
    Comment = { fg = "#6b9e87", italic = true },
    ["@comment"] = { fg = "#6b9e87", italic = true },
    LineNr = { fg = "#58856e", bg = "#101010" },
    CursorLineNr = { fg = "#a8d5bf", bg = "#101010" },
    Visual = { bg = "#164b36" },
    FloatBorder = { fg = "#58856e", bg = "#181818" },
    NvDashAscii = { fg = "#a8d5bf", bg = "#101010" },
    NvDashButtons = { fg = "#00e69a", bg = "#101010" },
  },
}
M.ui = {
  statusline = { theme = "minimal", separator_style = "block" },
  telescope = { style = "bordered" },
}
M.nvdash = { load_on_startup = true }
M.mason = { pkgs = { "lua-language-server", "stylua" } }
return M
