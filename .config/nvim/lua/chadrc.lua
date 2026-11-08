-- Custom theme; kept outside NvChad's built-in theme-name type list.
local M = {}
M.base46 = {
  theme = "blazepwn",
  transparency = false,
  theme_toggle = { "blazepwn", "xerux_black" },
  hl_override = {
    Normal = { bg = "#16181d", fg = "#dce2ec" },
    NormalNC = { bg = "#16181d" },
    NormalFloat = { bg = "#1c1f26" },
    CursorLine = { bg = "#21252e" },
    Comment = { fg = "#8792a8", italic = true },
    ["@comment"] = { fg = "#8792a8", italic = true },
    LineNr = { fg = "#5f6f94", bg = "#16181d" },
    CursorLineNr = { fg = "#dce2ec", bg = "#16181d" },
    Visual = { bg = "#23365a" },
    FloatBorder = { fg = "#5f6f94", bg = "#1c1f26" },
    NvDashAscii = { fg = "#dce2ec", bg = "#16181d" },
    NvDashButtons = { fg = "#60a5fa", bg = "#16181d" },
  },
}
M.ui = {
  statusline = { theme = "minimal", separator_style = "block" },
  telescope = { style = "bordered" },
}
M.nvdash = { load_on_startup = true }
M.mason = { pkgs = { "lua-language-server", "stylua" } }
return M
