-- Nosfeik: match Kitty and the Exegol prompt.
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.number = true

local function nosfeik()
  local groups = {
    Normal = { fg = "#dce2ec", bg = "#16181d" },
    NormalNC = { fg = "#dce2ec", bg = "#16181d" },
    NormalFloat = { fg = "#dce2ec", bg = "#1c1f26" },
    FloatBorder = { fg = "#5f6f94", bg = "#1c1f26" },
    SignColumn = { bg = "#16181d" },
    FoldColumn = { fg = "#8792a8", bg = "#16181d" },
    EndOfBuffer = { fg = "#475a8b", bg = "#16181d" },
    LineNr = { fg = "#5f6f94", bg = "#16181d" },
    CursorLineNr = { fg = "#60a5fa", bg = "#16181d" },
    CursorLine = { bg = "#21252e" },
    Visual = { bg = "#23365a" },
    Search = { fg = "#16181d", bg = "#60a5fa" },
    IncSearch = { fg = "#16181d", bg = "#dbeafe" },
    StatusLine = { fg = "#60a5fa", bg = "#1c1f26" },
    StatusLineNC = { fg = "#8792a8", bg = "#1c1f26" },
    WinSeparator = { fg = "#475a8b", bg = "#16181d" },
    VertSplit = { fg = "#475a8b", bg = "#16181d" },
    Pmenu = { fg = "#dce2ec", bg = "#1c1f26" },
    PmenuSel = { fg = "#16181d", bg = "#60a5fa" },
    Comment = { fg = "#8792a8", italic = true },
    Constant = { fg = "#4fb3f9" },
    String = { fg = "#a3c4f3" },
    Identifier = { fg = "#dce2ec" },
    Function = { fg = "#60a5fa" },
    Statement = { fg = "#3b82f6" },
    PreProc = { fg = "#93c5fd" },
    Type = { fg = "#6ea8f7" },
    Special = { fg = "#7dd3fc" },
    Underlined = { fg = "#60a5fa", underline = true },
    Error = { fg = "#dbeafe", bg = "#23365a", bold = true },
    ErrorMsg = { fg = "#dbeafe", bold = true },
    WarningMsg = { fg = "#a3c4f3" },
    Todo = { fg = "#60a5fa", bg = "#1e2b45", bold = true },
    Directory = { fg = "#60a5fa" },
    Title = { fg = "#60a5fa", bold = true },
    NonText = { fg = "#5f6f94" },
    MatchParen = { fg = "#dbeafe", bg = "#23365a", bold = true },
    DiffAdd = { bg = "#1e2b45" },
    DiffChange = { bg = "#20362b" },
    DiffDelete = { fg = "#8792a8", bg = "#1c1f26" },
    DiffText = { fg = "#16181d", bg = "#93c5fd" },
  }
  for name, attributes in pairs(groups) do
    vim.api.nvim_set_hl(0, name, attributes)
  end
end
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("Nosfeik", { clear = true }),
  callback = nosfeik,
})
nosfeik()
