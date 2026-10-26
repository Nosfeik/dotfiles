-- Green Black: match Kitty and the Exegol prompt.
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.number = true

local function green_black()
  local groups = {
    Normal = { fg = "#a8d5bf", bg = "#101010" },
    NormalNC = { fg = "#a8d5bf", bg = "#101010" },
    NormalFloat = { fg = "#a8d5bf", bg = "#181818" },
    FloatBorder = { fg = "#58856e", bg = "#181818" },
    SignColumn = { bg = "#101010" },
    FoldColumn = { fg = "#6b9e87", bg = "#101010" },
    EndOfBuffer = { fg = "#426651", bg = "#101010" },
    LineNr = { fg = "#58856e", bg = "#101010" },
    CursorLineNr = { fg = "#00e69a", bg = "#101010" },
    CursorLine = { bg = "#202020" },
    Visual = { bg = "#164b36" },
    Search = { fg = "#101010", bg = "#00e69a" },
    IncSearch = { fg = "#101010", bg = "#d5ffe9" },
    StatusLine = { fg = "#00e69a", bg = "#181818" },
    StatusLineNC = { fg = "#6b9e87", bg = "#181818" },
    WinSeparator = { fg = "#426651", bg = "#101010" },
    VertSplit = { fg = "#426651", bg = "#101010" },
    Pmenu = { fg = "#a8d5bf", bg = "#181818" },
    PmenuSel = { fg = "#101010", bg = "#00e69a" },
    Comment = { fg = "#6b9e87", italic = true },
    Constant = { fg = "#43e3a7" },
    String = { fg = "#8bd5a9" },
    Identifier = { fg = "#a8d5bf" },
    Function = { fg = "#00e69a" },
    Statement = { fg = "#00c985" },
    PreProc = { fg = "#65dfb3" },
    Type = { fg = "#59cfa0" },
    Special = { fg = "#52f5c5" },
    Underlined = { fg = "#00e69a", underline = true },
    Error = { fg = "#d5ffe9", bg = "#164b36", bold = true },
    ErrorMsg = { fg = "#d5ffe9", bold = true },
    WarningMsg = { fg = "#8bd5a9" },
    Todo = { fg = "#00e69a", bg = "#163a2c", bold = true },
    Directory = { fg = "#00e69a" },
    Title = { fg = "#00e69a", bold = true },
    NonText = { fg = "#58856e" },
    MatchParen = { fg = "#d5ffe9", bg = "#164b36", bold = true },
    DiffAdd = { bg = "#163a2c" },
    DiffChange = { bg = "#20362b" },
    DiffDelete = { fg = "#6b9e87", bg = "#181818" },
    DiffText = { fg = "#101010", bg = "#65dfb3" },
  }
  for name, attributes in pairs(groups) do
    vim.api.nvim_set_hl(0, name, attributes)
  end
end
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("GreenBlack", { clear = true }),
  callback = green_black,
})
green_black()
