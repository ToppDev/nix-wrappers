-- ayu_dark_plus: helix's ayu_dark theme plus the overrides the helix wrapper
-- layers on top, mapped onto Neovim's highlight groups.

vim.cmd.highlight "clear"
vim.g.colors_name = "ayu_dark_plus"
vim.o.background = "dark"

local c = {
  -- helix ayu_dark palette
  background = "#0f1419",
  foreground = "#bfbdb6",
  black = "#131721",
  blue = "#59c2ff",
  dark_gray = "#2d3640",
  cyan = "#73b8ff",
  gray = "#5c6773",
  green = "#aad94c",
  magenta = "#d2a6ff",
  orange = "#ff8f40",
  red = "#f07178",
  yellow = "#e6b450",
  -- ayu_dark_plus additions
  parameter = "#eba0ac",
  punct_special = "#89dceb",
  macro = "#f4a6f7",
  linenr = "#5c6773",
  linenr_cur = "#9da3ab",
  cursorline = "#252933",
  popup_fg = "#7b91b3",
  popup = "#16203b",
  menu = "#1f2430",
  lavender = "#b4befe",
  warning = "#ffed29",
  hint = "#99f291",
}

local groups = {
  -- [[ Editor UI ]]
  Normal = { fg = c.foreground, bg = c.background },
  NormalFloat = { fg = c.popup_fg, bg = c.popup },
  FloatBorder = { fg = c.popup_fg, bg = c.popup },
  FloatTitle = { fg = c.orange, bg = c.popup, bold = true },
  Cursor = { fg = c.dark_gray, bg = c.orange },
  lCursor = { link = "Cursor" },
  CursorLine = { bg = c.cursorline },
  CursorColumn = { bg = c.cursorline },
  ColorColumn = { bg = c.black },
  LineNr = { fg = c.linenr },
  CursorLineNr = { fg = c.linenr_cur },
  SignColumn = { fg = c.linenr },
  FoldColumn = { fg = c.linenr },
  Folded = { fg = c.gray, bg = c.black },
  MatchParen = { fg = c.dark_gray, bg = c.lavender },
  Visual = { bg = c.dark_gray },
  Search = { fg = c.background, bg = c.yellow },
  CurSearch = { fg = c.background, bg = c.orange },
  IncSearch = { link = "CurSearch" },
  Substitute = { link = "CurSearch" },
  WinSeparator = { fg = c.dark_gray },
  NonText = { fg = c.dark_gray },
  Whitespace = { fg = c.dark_gray },
  EndOfBuffer = { fg = c.background },
  StatusLine = { fg = c.foreground, bg = c.black },
  StatusLineNC = { fg = c.gray, bg = c.black },
  TabLine = { fg = c.gray, bg = c.background },
  TabLineSel = { fg = c.foreground, bg = c.dark_gray },
  TabLineFill = { bg = c.background },
  WinBar = { fg = c.foreground },
  WinBarNC = { fg = c.gray },
  Pmenu = { fg = c.foreground, bg = c.menu },
  PmenuSel = { fg = c.background, bg = c.gray },
  PmenuSbar = { bg = c.menu },
  PmenuThumb = { bg = c.gray },
  PmenuMatch = { fg = c.orange, bg = c.menu, bold = true },
  PmenuMatchSel = { fg = c.background, bg = c.gray, bold = true },
  Directory = { fg = c.blue },
  Title = { fg = c.orange, bold = true },
  ErrorMsg = { fg = c.red, bold = true },
  WarningMsg = { fg = c.warning },
  MoreMsg = { fg = c.green },
  ModeMsg = { fg = c.foreground },
  Question = { fg = c.green },
  QuickFixLine = { bg = c.cursorline },
  SpellBad = { sp = c.red, undercurl = true },
  SpellCap = { sp = c.blue, undercurl = true },
  SpellLocal = { sp = c.cyan, undercurl = true },
  SpellRare = { sp = c.magenta, undercurl = true },

  -- [[ Syntax ]] Treesitter captures fall back to these by default
  Comment = { fg = c.gray, italic = true },
  Constant = { fg = c.magenta },
  String = { fg = c.green },
  Character = { fg = c.magenta },
  Identifier = { fg = c.foreground },
  Function = { fg = c.yellow },
  Statement = { fg = c.orange },
  Conditional = { fg = c.orange },
  Repeat = { fg = c.yellow },
  Label = { fg = c.orange },
  Operator = { fg = c.orange },
  Keyword = { fg = c.orange },
  Exception = { fg = c.yellow },
  PreProc = { fg = c.yellow },
  Macro = { fg = c.macro },
  Type = { fg = c.blue },
  Special = { fg = c.orange },
  SpecialChar = { fg = c.magenta },
  Tag = { fg = c.blue },
  Delimiter = { fg = c.foreground },
  Underlined = { underline = true },
  Todo = { fg = c.background, bg = c.yellow, bold = true },
  Error = { fg = c.red },
  Added = { fg = c.green },
  Removed = { fg = c.red },
  Changed = { fg = c.yellow },
  DiffAdd = { fg = c.green, bg = c.black },
  DiffDelete = { fg = c.red, bg = c.black },
  DiffChange = { fg = c.yellow, bg = c.black },
  DiffText = { fg = c.background, bg = c.yellow },

  -- [[ Treesitter ]] only where helix scopes differ from the fallbacks
  ["@variable"] = { fg = c.foreground },
  ["@variable.parameter"] = { fg = c.parameter, italic = true },
  ["@variable.builtin"] = { fg = c.red },
  ["@attribute"] = { fg = c.red },
  ["@constructor"] = { fg = c.green },
  ["@module"] = { fg = c.blue },
  ["@string.regexp"] = { fg = c.orange },
  ["@string.special"] = { fg = c.yellow },
  ["@string.escape"] = { fg = c.magenta },
  ["@punctuation.special"] = { fg = c.punct_special },
  ["@keyword.directive"] = { fg = c.yellow },
  ["@keyword.return"] = { fg = c.yellow },
  ["@keyword.conditional"] = { fg = c.orange },
  ["@function.macro"] = { fg = c.macro },
  ["@tag.attribute"] = { fg = c.red },
  ["@tag.delimiter"] = { fg = c.foreground },

  ["@markup.heading"] = { fg = c.orange, bold = true },
  ["@markup.heading.1"] = { fg = "#cc3300", bold = true },
  ["@markup.heading.2"] = { fg = "#ff9966", bold = true },
  ["@markup.heading.3"] = { fg = "#eed202", bold = true },
  ["@markup.heading.4"] = { fg = "#a6e3a1", bold = true },
  ["@markup.heading.5"] = { fg = "#74c7ec", bold = true },
  ["@markup.heading.6"] = { fg = c.lavender, bold = true },
  ["@markup.list"] = { fg = c.yellow },
  ["@markup.list.checked"] = { fg = c.green },
  ["@markup.strong"] = { fg = c.orange, bold = true },
  ["@markup.italic"] = { fg = c.orange, italic = true },
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.raw"] = { fg = c.green },
  ["@markup.raw.block"] = { fg = c.green },
  ["@markup.link"] = { fg = c.yellow },
  ["@markup.link.url"] = { fg = c.blue, underline = true },
  ["@markup.link.label"] = { fg = c.green },
  ["@markup.quote"] = { fg = c.yellow },

  -- [[ Pickers ]] helix draws pickers on the editor background; the blue
  -- popup background is for hover and documentation windows only
  PickerNormal = { fg = c.foreground, bg = c.background },
  PickerBorder = { fg = c.gray, bg = c.background },
  PickerTitle = { fg = c.orange, bg = c.background, bold = true },
  PickerCursorLine = { bg = c.dark_gray },
  PickerMatch = { fg = c.orange, bold = true },
  SnacksPicker = { link = "PickerNormal" },
  SnacksPickerBorder = { link = "PickerBorder" },
  SnacksPickerTitle = { link = "PickerTitle" },
  SnacksPickerListCursorLine = { link = "PickerCursorLine" },
  SnacksPickerPreviewCursorLine = { link = "CursorLine" },
  SnacksPickerMatch = { link = "PickerMatch" },

  -- [[ Diagnostics and LSP ]]
  DiagnosticError = { fg = c.red, bold = true },
  DiagnosticWarn = { fg = c.warning, bold = true },
  DiagnosticInfo = { fg = c.blue, bold = true },
  DiagnosticHint = { fg = c.hint, bold = true },
  DiagnosticOk = { fg = c.green },
  DiagnosticUnderlineError = { sp = c.red, undercurl = true },
  DiagnosticUnderlineWarn = { sp = c.yellow, undercurl = true },
  DiagnosticUnderlineInfo = { sp = c.blue, undercurl = true },
  DiagnosticUnderlineHint = { sp = c.blue, undercurl = true },
  DiagnosticUnnecessary = { fg = c.gray },
  DiagnosticDeprecated = { strikethrough = true },
  LspInlayHint = { fg = "#87898c", bg = "#121b24" },
  LspCodeLens = { fg = c.gray, italic = true },
  LspReferenceText = { bg = c.dark_gray },
  LspReferenceRead = { bg = c.dark_gray },
  LspReferenceWrite = { bg = c.dark_gray, underline = true },
  LspSignatureActiveParameter = { fg = c.orange, bold = true },
}

for name, spec in pairs(groups) do
  vim.api.nvim_set_hl(0, name, spec)
end

vim.g.terminal_color_0 = c.black
vim.g.terminal_color_1 = c.red
vim.g.terminal_color_2 = c.green
vim.g.terminal_color_3 = c.yellow
vim.g.terminal_color_4 = c.blue
vim.g.terminal_color_5 = c.magenta
vim.g.terminal_color_6 = c.cyan
vim.g.terminal_color_7 = c.foreground
vim.g.terminal_color_8 = c.gray
vim.g.terminal_color_9 = c.red
vim.g.terminal_color_10 = c.green
vim.g.terminal_color_11 = c.yellow
vim.g.terminal_color_12 = c.blue
vim.g.terminal_color_13 = c.magenta
vim.g.terminal_color_14 = c.cyan
vim.g.terminal_color_15 = c.foreground
