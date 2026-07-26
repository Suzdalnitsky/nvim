-- This config targets a modern Neovim: it relies on APIs such as jobstart()'s
-- `term` option (0.11+). Bail with a clear message rather than failing with a
-- cryptic error deep inside a keymap later.
if vim.fn.has("nvim-0.11") ~= 1 then
  vim.api.nvim_echo({
    { "nvim config requires Neovim 0.11 or newer — config not loaded.\n", "ErrorMsg" },
  }, true, {})
  return {}
end

-- Color palette: named colors declared first (layer 1). Retune hex values here
-- and every role that maps to a name below follows automatically.
local palette = {
  white       = "#ffffff",
  black       = "#000000",
  deep_blue   = "#00008b",
  dark_green  = "#006400",
  medium_blue = "#0000cd",
  purple      = "#800080",
  green       = "#008000",
  red         = "#af0000",
  light_blue  = "#cce6ff",
  light_yellow = "#ffe680", -- search highlight
  light_gray  = "#e4e4e4",
  faint_gray  = "#d0d0d0",
  gray        = "#808080",
  -- One shared dark palette for the floating tools (LazyGit + Telescope), so the
  -- two stay visually aligned: retune here and both follow. (The Claude sidebar
  -- is deliberately plain white -- it uses the editor's own white/black, no
  -- separate palette.)
  float_bg    = "#1e1e1e",
  float_fg    = "#d4d4d4",
  orange      = "#ff8800", -- cursor in the dark popups: high contrast on every dark bg
}

-- Role -> palette-name mapping (layer 2). Each row maps a highlight group to a
-- palette color; the demo file (demo.lua) renders this table directly.
local roles = {
  { group = "Normal",         fg = "black",       bg = "white", label = "Normal text" },
  { group = "Identifier",     fg = "deep_blue",   label = "Identifiers (vars/functions)" },
  { group = "String",         fg = "dark_green",  label = "Strings" },
  { group = "Number",         fg = "medium_blue", label = "Numbers" },
  { group = "Constant",       fg = "purple",      label = "Constants / booleans" },
  { group = "Comment",        fg = "gray",        label = "Comments" },
  { group = "CursorLine",     bg = "light_blue",  label = "Cursor line (focused)" },
  { group = "GitSignsAdd",    fg = "green",       label = "Git added" },
  { group = "GitSignsChange", fg = "medium_blue", label = "Git changed" },
  { group = "GitSignsDelete", fg = "red",         label = "Git deleted" },
  { group = "Whitespace",     fg = "faint_gray",  label = "Whitespace (tabs / trailing)" },
}

local function apply_theme()
  for _, r in ipairs(roles) do
    vim.api.nvim_set_hl(0, r.group, {
      fg = r.fg and palette[r.fg] or nil,
      bg = r.bg and palette[r.bg] or nil,
    })
  end
  -- Secondary groups follow the roles above. Both the classic syntax groups and
  -- the treesitter @captures are set, so a buffer looks the same however it is
  -- parsed (Neovim highlights Lua via treesitter).
  local function link(target, groups)
    for _, g in ipairs(groups) do
      vim.api.nvim_set_hl(0, g, { link = target })
    end
  end
  -- Variable and function names (incl. builtins like tostring) -> deep blue.
  link("Identifier", {
    "Function", "@variable", "@variable.parameter", "@variable.member",
    "@function", "@function.call", "@function.builtin", "@function.method",
    "@function.method.call", "@property", "@module", "@constructor",
  })
  link("Number", { "Float", "@number", "@number.float" })
  link("String", { "@string", "@string.escape" })
  link("Constant", { "Boolean", "@boolean", "@constant", "@constant.builtin" })
  link("Comment", { "@comment" })
  link("Whitespace", { "NonText" })
  -- Everything the palette does not call out renders as plain black, no bold --
  -- this is what stops keywords (local/function/return/end) from being bold.
  for _, g in ipairs({
    "Statement", "Keyword", "Conditional", "Repeat", "Operator", "Exception",
    "Type", "StorageClass", "Structure", "PreProc", "Special", "Delimiter",
    "@keyword", "@keyword.function", "@keyword.return", "@keyword.operator",
    "@keyword.repeat", "@keyword.conditional", "@type", "@operator",
    "@punctuation", "@punctuation.bracket", "@punctuation.delimiter",
  }) do
    vim.api.nvim_set_hl(0, g, { fg = palette.black })
  end
  -- Focus-aware cursor line: focused window (light blue + bold number) vs the
  -- dimmed gray version used in unfocused windows.
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = palette.black, bold = true })
  vim.api.nvim_set_hl(0, "CursorLineUnfocused", { bg = palette.light_gray })
  vim.api.nvim_set_hl(0, "CursorLineNrUnfocused", { fg = palette.gray })
  -- Dark text caret for the white editor (the cursor_contrast autocmds swap it
  -- to orange over the dark floats). Set here so it survives any :colorscheme.
  vim.api.nvim_set_hl(0, "Cursor", { fg = palette.white, bg = palette.black })
  vim.api.nvim_set_hl(0, "lCursor", { fg = palette.white, bg = palette.black })
  -- Terminal-mode cursor: terminals only exist as dark floats in this config
  -- (Claude, LazyGit), so it is always the high-contrast orange block.
  vim.api.nvim_set_hl(0, "TermCursor", { fg = palette.black, bg = palette.orange })
  -- Core UI groups, themed to the light palette so a loaded colorscheme can't
  -- leave them a mismatched half-dark (this config re-applies on ColorScheme).
  vim.api.nvim_set_hl(0, "Visual", { bg = palette.light_blue })
  vim.api.nvim_set_hl(0, "Search", { fg = palette.black, bg = palette.light_yellow })
  vim.api.nvim_set_hl(0, "IncSearch", { fg = palette.black, bg = palette.orange })
  vim.api.nvim_set_hl(0, "CurSearch", { fg = palette.black, bg = palette.orange })
  vim.api.nvim_set_hl(0, "Pmenu", { fg = palette.black, bg = palette.light_gray })
  vim.api.nvim_set_hl(0, "PmenuSel", { fg = palette.white, bg = palette.deep_blue, bold = true })
  vim.api.nvim_set_hl(0, "PmenuSbar", { bg = palette.faint_gray })
  vim.api.nvim_set_hl(0, "PmenuThumb", { bg = palette.gray })
  vim.api.nvim_set_hl(0, "StatusLine", { fg = palette.black, bg = palette.light_gray })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = palette.gray, bg = palette.faint_gray })
  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = palette.red })
  vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = palette.orange })
  vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = palette.medium_blue })
  vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = palette.gray })
  -- LazyGit float (separate dark palette).
  vim.api.nvim_set_hl(0, "LazyGitNormal", { fg = palette.float_fg, bg = palette.float_bg })
  vim.api.nvim_set_hl(0, "LazyGitBorder", { fg = palette.float_fg, bg = palette.float_bg })
  -- Claude sidebar: a plain white terminal, intentionally identical to the
  -- editor and unaffected by the rest of the theme (no dark mode, no accent).
  vim.api.nvim_set_hl(0, "ClaudeNormal", { fg = palette.black, bg = palette.white })
  -- Telescope: dark search UI (prompt + results) like the LazyGit float. The
  -- preview stays light so previewed code keeps the editor's readable syntax
  -- colors (dark syntax on a dark background is what looked broken).
  for _, g in ipairs({
    "TelescopeNormal", "TelescopeBorder",
    "TelescopePromptNormal", "TelescopePromptBorder", "TelescopePromptTitle",
    "TelescopeResultsNormal", "TelescopeResultsBorder", "TelescopeResultsTitle",
  }) do
    vim.api.nvim_set_hl(0, g, { fg = palette.float_fg, bg = palette.float_bg })
  end
  vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = palette.light_blue, bg = palette.float_bg })
  vim.api.nvim_set_hl(0, "TelescopePromptCounter", { fg = palette.float_fg, bg = palette.float_bg })
  -- Prominent navy selection bar so the highlighted entry doesn't blend in.
  vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = palette.float_fg, bg = palette.deep_blue, bold = true })
  vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { fg = palette.light_blue, bg = palette.deep_blue, bold = true })
  vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = palette.light_blue, bold = true })
  -- Preview stays light and readable.
  for _, g in ipairs({ "TelescopePreviewNormal", "TelescopePreviewBorder", "TelescopePreviewTitle" }) do
    vim.api.nvim_set_hl(0, g, { fg = palette.black, bg = palette.white })
  end
end

-- Always a white background: light mode, and reapply the theme after any
-- :colorscheme so nothing can override it.
local function reapply_theme()
  -- A loaded colorscheme often flips &background to dark; force it back so the
  -- palette stays a light theme. Guard the write: setting &background can itself
  -- re-fire ColorScheme, and the guard makes that converge instead of recurse.
  if vim.o.background ~= "light" then
    vim.o.background = "light"
  end
  apply_theme()
end

-- Truecolor so the hex palette renders exactly, and so the cursor color below
-- can actually be set (Neovim only drives the terminal cursor color under
-- 'termguicolors').
vim.opt.termguicolors = true

-- In a terminal the cursor is painted by the terminal emulator, and Neovim only
-- tells it what color to use (OSC 12) for modes whose 'guicursor' entry names a
-- highlight group. The default attaches no group to normal/insert mode, so
-- without this line every Cursor highlight below would be dead code and the
-- terminal would keep its own (black) cursor everywhere, dark popups included.
vim.opt.guicursor =
  "n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor,t:block-blinkon500-blinkoff500-TermCursor"

vim.o.background = "light"
apply_theme()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("theme", { clear = true }),
  callback = reapply_theme,
})

-- Cursor contrast: black cursor on light backgrounds (the white editor and the
-- white Claude terminal), orange cursor on the dark popups (Telescope's prompt
-- and the LazyGit terminal), for the insert bar, the normal-mode block, AND the
-- terminal-mode block. The swap happens on the events that mark the popup rather
-- than by inspecting the focused window, because Telescope's prompt is not
-- always the current window while its buffer is active. The Claude terminal is
-- flagged (b:claude_terminal) so it stays on the light caret like the editor.
local function poke_guicursor()
  -- Re-setting 'guicursor' makes the TUI re-send the cursor color (OSC 12) for
  -- the current mode right away; on its own it only does so on mode changes,
  -- which can land before the autocmd that swapped the color.
  vim.o.guicursor = vim.o.guicursor
end
local function editor_cursor()
  vim.api.nvim_set_hl(0, "Cursor", { fg = palette.white, bg = palette.black })
  vim.api.nvim_set_hl(0, "lCursor", { fg = palette.white, bg = palette.black })
  poke_guicursor()
end
local function float_cursor()
  vim.api.nvim_set_hl(0, "Cursor", { fg = palette.black, bg = palette.orange })
  vim.api.nvim_set_hl(0, "lCursor", { fg = palette.black, bg = palette.orange })
  poke_guicursor()
end
-- The terminal-mode block caret (guicursor `t:...TermCursor`). Dark terminals
-- (LazyGit) get the orange block; the white Claude terminal gets the same black
-- block as the editor. "dark" is the resting default, restored on leaving a
-- terminal so an idle TermCursor always matches the dark floats.
local function term_caret(mode)
  if mode == "light" then
    vim.api.nvim_set_hl(0, "TermCursor", { fg = palette.white, bg = palette.black })
  else
    vim.api.nvim_set_hl(0, "TermCursor", { fg = palette.black, bg = palette.orange })
  end
  poke_guicursor()
end

local cursor_group = vim.api.nvim_create_augroup("cursor_contrast", { clear = true })
-- Telescope sets its filetype after entering the prompt window, so key off
-- FileType; terminals fire TermOpen when created and BufEnter when a hidden
-- session is re-shown.
vim.api.nvim_create_autocmd("FileType", {
  group = cursor_group,
  pattern = "TelescopePrompt",
  callback = float_cursor,
})
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
  group = cursor_group,
  callback = function()
    if vim.bo.buftype == "terminal" then
      if vim.b.claude_terminal then
        editor_cursor() -- white Claude terminal -> black caret, like the editor
        term_caret("light")
      else
        float_cursor() -- dark terminal (LazyGit) -> orange caret
        term_caret("dark")
      end
    end
  end,
})
vim.api.nvim_create_autocmd("BufLeave", {
  group = cursor_group,
  callback = function()
    -- BufLeave fires with the buffer being left still current: restore the
    -- editor caret whenever we step out of a float/terminal, and reset the
    -- terminal-mode caret to its dark-float default.
    if vim.bo.filetype == "TelescopePrompt" or vim.bo.buftype == "terminal" then
      editor_cursor()
      term_caret("dark")
    end
  end,
})

-- Focus-aware cursor line for the sidebars (the neo-tree explorer and the Claude
-- terminal): their cursor line is light blue when focused and dimmed gray when
-- you're editing elsewhere, so it's obvious which pane has focus. Editor windows
-- are left untouched. Done per window via winhighlight so each window's own
-- highlights (neo-tree's, or Claude's white Normal) are preserved.
local UNFOCUSED = { CursorLine = "CursorLineUnfocused", CursorLineNr = "CursorLineNrUnfocused" }

local function set_win_focus(win, focused)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].filetype ~= "neo-tree" and not vim.b[buf].claude_terminal then
    return -- only the sidebars get the focus dimming, not editor windows
  end
  vim.wo[win].cursorline = true
  local kept = {}
  for pair in vim.gsplit(vim.wo[win].winhighlight, ",", { trimempty = true }) do
    local k, v = pair:match("^(.-):(.*)$")
    if k and not UNFOCUSED[k] then
      kept[#kept + 1] = k .. ":" .. v
    end
  end
  if not focused then
    for k, v in pairs(UNFOCUSED) do
      kept[#kept + 1] = k .. ":" .. v
    end
  end
  vim.wo[win].winhighlight = table.concat(kept, ",")
end

local function refresh_focus()
  local cur = vim.api.nvim_get_current_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    set_win_focus(win, win == cur)
  end
end

local focus_group = vim.api.nvim_create_augroup("focus_hl", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "VimEnter" }, {
  group = focus_group,
  callback = refresh_focus,
})
vim.api.nvim_create_autocmd("WinNew", {
  group = focus_group,
  callback = function()
    vim.schedule(refresh_focus)
  end,
})

-- Demo support: when a color-scheme demo file (in demos/) is opened, paint a
-- colored swatch at the end of each palette line so every color is visible (a
-- plain buffer can only render the syntax colors on its own). Guarded to demos/
-- files carrying the header marker, so it never touches other files. The
-- comment leader may be -- (lua) or // (swift/java).
local demo_ns = vim.api.nvim_create_namespace("color_demo")
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("color_demo", { clear = true }),
  pattern = "*demos/*",
  callback = function(ev)
    local first = vim.api.nvim_buf_get_lines(ev.buf, 0, 1, false)[1] or ""
    if not first:find("Color%-scheme demo") then
      return
    end
    vim.api.nvim_buf_clear_namespace(ev.buf, demo_ns, 0, -1)
    local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
    for i, line in ipairs(lines) do
      local name = line:match("^%s*[%-/][%-/]%s+([%a_]+)%s+#%x%x%x%x%x%x")
      if name and palette[name] then
        local group = "DemoSwatch_" .. name
        vim.api.nvim_set_hl(0, group, { bg = palette[name] })
        vim.api.nvim_buf_set_extmark(ev.buf, demo_ns, i - 1, 0, {
          virt_text = { { "  ", "Normal" }, { "      ", group } },
          virt_text_pos = "eol",
        })
      end
    end
  end,
})

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- A single global statusline at the very bottom instead of one per window, so
-- the sidebars (neo-tree, Claude) carry no status bar of their own -- Neovim has
-- no per-window "hide the statusline", and this is the clean way to drop them.
vim.opt.laststatus = 3

-- Hybrid line numbers: absolute on the current line, relative elsewhere.
vim.opt.number = true
vim.opt.relativenumber = true

-- Always make tabs and trailing whitespace visible.
vim.opt.list = true
vim.opt.listchars = { tab = "-->", trail = "·" }

-- Tabs are 4 columns wide.
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Claude's session state. Declared up here (not next to its functions below) so
-- the window helpers -- first_editor_win and the single-editor enforcer -- can
-- recognize and skip the Claude sidebar, which is a real (non-floating) window
-- like neo-tree, not an editor window.
local claude = { buf = nil, job = nil, win = nil }

local function explorer_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      return win
    end
  end
  return nil
end

local function first_editor_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    -- Skip both sidebars (the neo-tree explorer and the Claude terminal): the
    -- "editor window" is the real file-editing pane between them.
    if vim.bo[buf].filetype ~= "neo-tree" and buf ~= claude.buf then
      return win
    end
  end
  return nil
end

local function file_in_cwd(path)
  if path == "" then
    return false
  end
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")
  return vim.startswith(vim.fn.fnamemodify(path, ":p"), cwd)
end

-- Named so the same action can be bound in the Claude terminal too (see the
-- terminal-mode <leader> maps in show_claude below).
local function toggle_explorer()
  local win = explorer_win()
  if win then
    if vim.api.nvim_get_current_win() == win then
      vim.cmd("Neotree close")
    else
      vim.api.nvim_set_current_win(win)
    end
  else
    local file = vim.api.nvim_buf_get_name(0)
    if file_in_cwd(file) then
      vim.cmd("Neotree reveal")
    else
      vim.cmd("Neotree focus")
    end
  end
end
vim.keymap.set("n", "<leader>1", toggle_explorer, { desc = "Toggle file explorer" })

local function focus_editor()
  local win = first_editor_win()
  if win then
    vim.api.nvim_set_current_win(win)
  end
end
vim.keymap.set("n", "<leader>2", focus_editor, { desc = "Focus main editor window" })

-- <leader>3 hides every sidebar at once (the explorer and the Claude terminal);
-- see hide_all_sidebars below, defined once hide_claude is in scope.

-- Telescope pickers. Every picker first jumps out of the explorer (if you were
-- in it) so results always open in the real editor window.
local function leave_explorer()
  local ex = explorer_win()
  if ex and vim.api.nvim_get_current_win() == ex then
    local editor = first_editor_win()
    if editor then
      vim.api.nvim_set_current_win(editor)
    end
  end
end

-- Find files and recent files open as a compact, preview-less picker: a centered
-- box half the screen wide and tall. Fresh table per call so Telescope can
-- annotate its own opts. (Live grep keeps the default full-size picker + preview.)
local function compact_layout(extra)
  return vim.tbl_extend("force", {
    previewer = false,
    layout_config = { width = 0.5, height = 0.5 },
  }, extra or {})
end

vim.keymap.set("n", "<leader>n", function()
  leave_explorer()
  require("telescope.builtin").find_files(compact_layout())
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>e", function()
  leave_explorer()
  require("telescope.builtin").oldfiles(compact_layout({ initial_mode = "normal" }))
end, { desc = "Recently opened files" })

-- Live grep that remembers the text you last searched for (this session). The
-- query is captured as it's typed via an autocmd, so we don't remap <Esc>/<CR>
-- -- <Esc> keeps its normal behavior of entering telescope's normal mode.
local last_grep = ""
vim.keymap.set("n", "<leader>f", function()
  leave_explorer()
  local state = require("telescope.actions.state")
  require("telescope.builtin").live_grep({
    default_text = last_grep,
    attach_mappings = function(prompt_bufnr, _)
      vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
        buffer = prompt_bufnr,
        callback = function()
          last_grep = state.get_current_line()
        end,
      })
      return true
    end,
  })
end, { desc = "Live grep (remembers last search)" })

-- LazyGit in a floating terminal (~90% of the screen). Its dark palette
-- (LazyGitNormal / LazyGitBorder) is defined in apply_theme above.

-- Launch lazygit with an extra config file that sets quitOnTopLevelReturn, so
-- pressing <Esc> at the top level quits lazygit (closing the float) without us
-- swallowing <Esc> -- it still works for lazygit's own navigation. The override
-- is merged on top of the user's own lazygit config so nothing is lost.
local lazygit_config_arg
local function ensure_lazygit_config()
  if lazygit_config_arg then
    return lazygit_config_arg
  end
  local cache = vim.fn.stdpath("cache")
  vim.fn.mkdir(cache, "p") -- may not exist yet on a fresh machine
  local override = cache .. "/lazygit-nvim.yml"
  vim.fn.writefile({ "quitOnTopLevelReturn: true" }, override)
  local dir = vim.trim(vim.fn.system({ "lazygit", "--print-config-dir" }))
  local user_cfg = dir .. "/config.yml"
  if vim.v.shell_error == 0 and vim.fn.filereadable(user_cfg) == 1 then
    lazygit_config_arg = user_cfg .. "," .. override
  else
    lazygit_config_arg = override
  end
  return lazygit_config_arg
end

-- Geometry for a centered float filling ~90% of the screen (the LazyGit float).
-- Claude no longer uses this -- it lives in a right-hand sidebar (see below).
local function float_win_config()
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  return {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  }
end

-- Run `cmd` (an argv list) in a one-shot floating terminal: the float and its
-- scratch buffer are torn down when the process exits. Used by the LazyGit
-- float; Claude uses a persistent sidebar split instead (see below).
local function open_float_term(cmd, winhighlight)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, float_win_config())
  vim.wo[win].winhighlight = winhighlight

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  vim.fn.jobstart(cmd, { term = true, on_exit = close })
  vim.cmd("startinsert")
end

local function open_lazygit(git_arg)
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify(
      "lazygit not found on PATH. Install it: https://github.com/jesseduffield/lazygit#installation",
      vim.log.levels.ERROR
    )
    return
  end
  local cmd = { "lazygit", "--use-config-file", ensure_lazygit_config() }
  if git_arg then
    table.insert(cmd, git_arg)
  end
  open_float_term(cmd, "Normal:LazyGitNormal,FloatBorder:LazyGitBorder")
end

vim.keymap.set("n", "<leader>k", function()
  open_lazygit()
end, { desc = "Open LazyGit" })

vim.keymap.set("n", "<leader>4", function()
  open_lazygit("log")
end, { desc = "Open LazyGit at the commit log" })

-- Claude Code in a *persistent* right-hand sidebar terminal -- a real split
-- (full height, half the width), not a float -- rendered as a plain white
-- terminal (ClaudeNormal, defined in apply_theme above): intentionally the same
-- white/black as the editor and unaffected by the rest of the theme. It behaves
-- like the neo-tree explorer: <leader>5 shows it, focuses it when it's open but
-- unfocused, and hides it when you're already in it. Hiding (<leader>5 or
-- <leader>3) only closes the window -- the Claude process keeps running in a
-- hidden buffer and reappears where you left it. The session ends only when
-- Claude itself exits. (The `claude` state table is declared near the top of
-- the file so the window helpers can skip this sidebar.)
-- <Esc> is deliberately NOT mapped in the terminal, so every Escape reaches
-- Claude untouched.

local function claude_visible()
  return claude.win ~= nil and vim.api.nvim_win_is_valid(claude.win)
end

local function hide_claude()
  if claude_visible() then
    -- Closing the sidebar when it is the last window fails (E444: cannot close
    -- last window). Only forget claude.win once the close actually succeeds --
    -- nulling it regardless would desync state and let the next <leader>5 open a
    -- second pane on the same session. In that (rare) sole-window case hide is a
    -- no-op: open another window first, then hide.
    if not pcall(vim.api.nvim_win_close, claude.win, true) then -- window only; job survives
      return
    end
  end
  claude.win = nil
end

-- Is Claude's input box empty? Read from the ❯ prompt line on Claude's rendered
-- screen (the last one -- transcript echoes also start with ❯). Empty means: no
-- prompt line, blank input, or the dimmed `Try "..."` placeholder of a fresh
-- session. Pure (takes the visible lines) so it's unit-testable against real
-- captured screens. Normalizes the no-break spaces (U+00A0) Claude renders after
-- the prompt char, or the check misreads.
local CLAUDE_PROMPT = "❯"

local function claude_prompt_empty(lines)
  local prompt_text
  for _, line in ipairs(lines) do
    local norm = line:gsub("\194\160", " ")
    if vim.startswith(norm, CLAUDE_PROMPT) then
      prompt_text = vim.trim(norm:sub(#CLAUDE_PROMPT + 1))
    end
  end
  return prompt_text == nil
    or prompt_text == ""
    or prompt_text:match('^Try ".*"$') ~= nil
end

local function claude_input_empty()
  if not (claude.buf and vim.api.nvim_buf_is_valid(claude.buf)) then
    return true
  end
  -- The live screen is the last <window height> rows; scrollback above it can
  -- hold stale frames with an old, non-empty prompt.
  local rows = claude_visible() and vim.api.nvim_win_get_height(claude.win) or vim.o.lines
  local total = vim.api.nvim_buf_line_count(claude.buf)
  local lines = vim.api.nvim_buf_get_lines(claude.buf, math.max(0, total - rows), -1, false)
  return claude_prompt_empty(lines)
end

-- The editor's <leader> maps are normal-mode only, so while you're typing in the
-- Claude terminal (terminal-insert mode) they'd otherwise be swallowed by Claude.
-- We rebind <leader>+number inside the Claude buffer to the same editor actions
-- (see setup_claude_term_keymaps below, forward-declared here because it uses
-- toggle_claude / hide_all_sidebars, defined further down). But only when the
-- input box is empty: with text in the prompt, <Space>+digit is passed straight
-- to Claude so you can still type "5 apples". Wrapper for the action case: leave
-- terminal-insert first (<C-\><C-n>) so window/tree navigation lands cleanly,
-- then run the action on the next tick.
local setup_claude_term_keymaps

local function from_claude_terminal(fn)
  return function()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
    vim.schedule(fn)
  end
end

-- Open the session buffer in a right-hand sidebar: a full-height split on the
-- far right (`botright vsplit`), resized to half the editor width. winfixwidth
-- keeps that width when other windows open/close (e.g. toggling the explorer).
local function open_claude_sidebar()
  vim.cmd("botright vsplit")
  claude.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(claude.win, claude.buf)
  vim.api.nvim_win_set_width(claude.win, math.floor(vim.o.columns * 0.5))
  -- Plain white terminal (ClaudeNormal = editor white/black); no accent border.
  vim.wo[claude.win].winhighlight = "Normal:ClaudeNormal"
  vim.wo[claude.win].winfixwidth = true
  -- A terminal pane, not a file: no line numbers or sign column to clutter it.
  vim.wo[claude.win].number = false
  vim.wo[claude.win].relativenumber = false
  vim.wo[claude.win].signcolumn = "no"
end

local function show_claude()
  -- Opening a window while the command-line window (q:, q/) is open raises E11;
  -- refuse rather than half-start a session that leaves the sidebar bricked.
  if vim.fn.getcmdwintype() ~= "" then
    return
  end
  local starting = not (claude.buf and vim.api.nvim_buf_is_valid(claude.buf))
  if starting then
    if vim.fn.executable("claude") ~= 1 then
      vim.notify(
        "claude not found on PATH. Install Claude Code: https://docs.claude.com/en/docs/claude-code",
        vim.log.levels.ERROR
      )
      return
    end
    claude.buf = vim.api.nvim_create_buf(false, true)
    -- Marks this terminal as the white Claude pane so the cursor-contrast
    -- autocmds give it the editor's black caret instead of the dark-float orange.
    vim.b[claude.buf].claude_terminal = true
  end

  -- The split can fail (E36 "not enough room" in a narrow terminal). If it does
  -- while we're starting, tear down the half-built session so the next
  -- <leader>5 retries from scratch instead of re-showing a dead, job-less buffer.
  if not pcall(open_claude_sidebar) then
    if starting then
      if claude.buf and vim.api.nvim_buf_is_valid(claude.buf) then
        pcall(vim.api.nvim_buf_delete, claude.buf, { force = true })
      end
      claude.buf, claude.job, claude.win = nil, nil, nil
    end
    vim.notify("Could not open the Claude sidebar (not enough room).", vim.log.levels.ERROR)
    return
  end

  if starting then
    -- jobstart with term=true turns the *current* buffer into a terminal, so the
    -- sidebar (showing claude.buf) must already be the focused window above.
    claude.job = vim.fn.jobstart({ "claude" }, {
      term = true,
      on_exit = function()
        -- Claude actually exited: tear the session down for real and reset, so
        -- the next <leader>5 starts fresh.
        if claude_visible() then
          pcall(vim.api.nvim_win_close, claude.win, true)
        end
        if claude.buf and vim.api.nvim_buf_is_valid(claude.buf) then
          pcall(vim.api.nvim_buf_delete, claude.buf, { force = true })
        end
        claude.buf, claude.job, claude.win = nil, nil, nil
      end,
    })
    vim.bo[claude.buf].bufhidden = "hide" -- keep the terminal alive while hidden
    setup_claude_term_keymaps(claude.buf)
  end
  vim.cmd("startinsert")
end

-- <leader>5, mirroring the explorer's <leader>1: focus the sidebar when it's
-- open but you're elsewhere, hide it when you're already in it, and open it
-- (starting Claude the first time) when it's closed.
local function toggle_claude()
  if claude_visible() then
    if vim.api.nvim_get_current_win() == claude.win then
      hide_claude()
    else
      vim.api.nvim_set_current_win(claude.win)
      vim.cmd("startinsert") -- drop straight into the terminal, ready to type
    end
  else
    show_claude()
  end
end

-- <leader>3: hide every sidebar at once. Neotree is pcall'd so a bare Neovim
-- without the plugin (the test runner) still hides the Claude sidebar.
local function hide_all_sidebars()
  pcall(vim.cmd, "Neotree close")
  hide_claude()
end

-- Buffer-local terminal-mode maps so the editor's <leader>+number keys keep
-- working while you're typing inside Claude. Buffer-local (not a global `t` map)
-- so other terminals -- the LazyGit float -- keep their own keys. Assigns the
-- forward-declared upvalue above. Because <leader> is <Space>, this would claim
-- <Space>1..<Space>5 inside the terminal, so each map only runs the editor
-- action when Claude's input is empty; with text in the prompt the literal
-- <Space><digit> is forwarded to Claude instead (so "5 apples" still types).
function setup_claude_term_keymaps(buf)
  local actions = {
    ["1"] = toggle_explorer,
    ["2"] = focus_editor,
    ["3"] = hide_all_sidebars,
    ["4"] = function() open_lazygit("log") end,
    ["5"] = toggle_claude,
  }
  for key, fn in pairs(actions) do
    local run_action = from_claude_terminal(fn)
    vim.keymap.set("t", "<leader>" .. key, function()
      if claude_input_empty() then
        run_action()
      else
        vim.fn.chansend(claude.job, " " .. key) -- forward <Space><digit> to Claude
      end
    end, { buffer = buf, desc = "Editor <leader>" .. key .. " (only when Claude's input is empty)" })
  end
end

-- Exposed for tests to tear a spawned session down deterministically.
local function claude_cleanup()
  if claude.job then
    pcall(vim.fn.jobstop, claude.job)
  end
  if claude.win and vim.api.nvim_win_is_valid(claude.win) then
    pcall(vim.api.nvim_win_close, claude.win, true)
  end
  if claude.buf and vim.api.nvim_buf_is_valid(claude.buf) then
    pcall(vim.api.nvim_buf_delete, claude.buf, { force = true })
  end
  claude.buf, claude.job, claude.win = nil, nil, nil
end

vim.keymap.set("n", "<leader>5", toggle_claude, { desc = "Toggle/focus Claude sidebar (hide keeps it running)" })
vim.keymap.set("n", "<leader>3", hide_all_sidebars, { desc = "Hide all sidebars (explorer + Claude)" })

-- Quit aliases: :q / :q! / :wq quit the whole editor (:qa / :qa! / :wqa).
-- Defining `q` and `wq` is enough: typing `!` after them expands the base
-- word first, so :q! becomes :qa! and :wq! becomes :wqa! for free.
local function cmd_alias(lhs, rhs)
  vim.cmd(string.format(
    "cnoreabbrev <expr> %s (getcmdtype() == ':' && getcmdline() ==# '%s') ? '%s' : '%s'",
    lhs, lhs, rhs, lhs
  ))
end
cmd_alias("q", "qa")
cmd_alias("wq", "wqa")

-- Single-editor policy: no splits, no tabs.
local function block_window()
  vim.notify("Splits and tabs are disabled (single-editor mode)", vim.log.levels.WARN)
end

for _, lhs in ipairs({
  "<C-w>s", "<C-w>v", "<C-w>n",
  "<C-w><C-s>", "<C-w><C-v>", "<C-w><C-n>",
  "<C-w>T", -- move the current window into a new tab
}) do
  vim.keymap.set("n", lhs, block_window, { desc = "Blocked: splits/tabs disabled" })
end

vim.api.nvim_create_user_command("BlockedWindow", block_window, {})
for _, name in ipairs({
  "split", "sp", "vsplit", "vs", "vsp", "new", "vnew", "vne", -- splits
  "tabnew", "tabedit", "tabe", "tabfind", "tabf", -- tabs
}) do
  cmd_alias(name, "BlockedWindow")
end

local function is_floating(win)
  return vim.api.nvim_win_get_config(win).relative ~= ""
end

-- Safety net: if a plugin or command opens a second real editor window anyway,
-- fold whatever the user is looking at into the one main window and close the
-- rest; likewise collapse any duplicate explorer window. Floating windows
-- (telescope, lazygit, neo-tree popups) are left alone, and so is the Claude
-- sidebar -- like the explorer, it's a legitimate second window, not an editor.
local function enforce_single_window()
  -- The command-line window (q:, q/) is a normal, non-floating window but
  -- mutating buffers/windows while it is open raises E11. Never touch it.
  if vim.fn.getcmdwintype() ~= "" then
    return
  end
  local editors, explorers = {}, {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if not is_floating(win) and win ~= claude.win then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "neo-tree" then
        table.insert(explorers, win)
      else
        table.insert(editors, win)
      end
    end
  end

  if #editors > 1 then
    local survivor = editors[1]
    local cur = vim.api.nvim_get_current_win()
    if not is_floating(cur) and cur ~= claude.win
      and vim.bo[vim.api.nvim_win_get_buf(cur)].filetype ~= "neo-tree" then
      pcall(vim.api.nvim_win_set_buf, survivor, vim.api.nvim_win_get_buf(cur))
    end
    for i = 2, #editors do
      pcall(vim.api.nvim_win_close, editors[i], false)
    end
    if vim.api.nvim_win_is_valid(survivor) then
      pcall(vim.api.nvim_set_current_win, survivor)
    end
  end

  if #explorers > 1 then
    for i = 2, #explorers do
      pcall(vim.api.nvim_win_close, explorers[i], false)
    end
  end
end

-- Safety net for the no-tabs half of the policy: the command/chord blocks above
-- only catch typed input, so if something opens a tab programmatically, collapse
-- back to the first tab. Buffers stay loaded (they just leave their tab's
-- windows), so nothing is lost.
local function enforce_single_tab()
  if #vim.api.nvim_list_tabpages() <= 1 then
    return
  end
  vim.notify("Tabs are disabled (single-editor mode)", vim.log.levels.WARN)
  vim.cmd("silent! tabfirst")
  vim.cmd("silent! tabonly!")
end

local single_editor_group = vim.api.nvim_create_augroup("single_window", { clear = true })
vim.api.nvim_create_autocmd("WinNew", {
  group = single_editor_group,
  callback = function()
    vim.schedule(enforce_single_window)
  end,
})
vim.api.nvim_create_autocmd("TabNew", {
  group = single_editor_group,
  callback = function()
    vim.schedule(enforce_single_tab)
  end,
})

-- Autosave: save a buffer automatically when you leave insert mode, change
-- text, lose focus, or leave the buffer -- but only for a normal, writable,
-- named file that lives inside the directory Neovim was launched in. Special
-- buffers, read-only buffers, unnamed buffers, and files opened from outside
-- the project (e.g. SDK/stdlib sources jumped to via LSP) are skipped, so you
-- should rarely need to type :w and never accidentally overwrite foreign files.
local function should_autosave(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.bo[buf].buftype == ""
    and vim.bo[buf].modifiable
    and not vim.bo[buf].readonly
    and vim.bo[buf].modified
    and file_in_cwd(vim.api.nvim_buf_get_name(buf))
end

-- Tracks buffers we've already warned about, so a failing write is reported
-- once (not on every TextChanged) until the buffer saves cleanly again.
local autosave_warned = {}

local function autosave(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not should_autosave(buf) then
    return
  end
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent! update")
  end)
  -- `silent!` suppresses the error, so the buffer staying `modified` is how we
  -- know the write actually failed (permissions, disk full, vanished dir).
  if vim.bo[buf].modified then
    if not autosave_warned[buf] then
      autosave_warned[buf] = true
      vim.notify(
        "Autosave failed for " .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
          .. " — save manually with :w",
        vim.log.levels.WARN
      )
    end
  else
    autosave_warned[buf] = nil
  end
end

-- Debounce text-change saves: normal-mode edits (x, p, dd, undo, ...) each fire
-- TextChanged, and writing on every one would hammer the disk and the gitsigns
-- / neo-tree file watchers. Coalesce a burst into a single write ~300ms after
-- it stops. The natural commit points below (leaving insert, losing focus,
-- leaving the buffer) still save immediately and cancel any pending timer.
local AUTOSAVE_DEBOUNCE_MS = 300
local autosave_timer

local function cancel_autosave_timer()
  if autosave_timer then
    autosave_timer:stop()
    if not autosave_timer:is_closing() then
      autosave_timer:close()
    end
    autosave_timer = nil
  end
end

local function debounce_autosave()
  local buf = vim.api.nvim_get_current_buf()
  cancel_autosave_timer()
  local timer = (vim.uv or vim.loop).new_timer()
  autosave_timer = timer
  timer:start(AUTOSAVE_DEBOUNCE_MS, 0, vim.schedule_wrap(function()
    -- A newer burst may have replaced autosave_timer while this callback waited
    -- to drain. If so, this timer is stale: its successor owns the pending save,
    -- and cancelling here would wrongly cancel that live timer. Bail out and let
    -- only the current timer commit.
    if autosave_timer ~= timer then
      return
    end
    cancel_autosave_timer()
    autosave(buf)
  end))
end

local function autosave_now()
  cancel_autosave_timer()
  autosave()
end

local autosave_group = vim.api.nvim_create_augroup("autosave", { clear = true })
vim.api.nvim_create_autocmd("TextChanged", {
  group = autosave_group,
  callback = debounce_autosave,
})
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost", "BufLeave" }, {
  group = autosave_group,
  callback = autosave_now,
})

-- Ensure every saved file ends with a trailing newline (a proper POSIX text
-- file), regardless of how the file was originally loaded.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("final_newline", { clear = true }),
  callback = function()
    if vim.bo.binary then
      return -- a binary file must keep its bytes exactly; never append a newline
    end
    vim.bo.endofline = true
    vim.bo.fixendofline = true
  end,
})

-- Exposed for the test suite; the config itself only relies on the side
-- effects above (leader keys + keymaps).
return {
  explorer_win = explorer_win,
  first_editor_win = first_editor_win,
  leave_explorer = leave_explorer,
  file_in_cwd = file_in_cwd,
  enforce_single_window = enforce_single_window,
  enforce_single_tab = enforce_single_tab,
  should_autosave = should_autosave,
  autosave = autosave,
  palette = palette,
  roles = roles,
  refresh_focus = refresh_focus,
  toggle_claude = toggle_claude,
  show_claude = show_claude,
  hide_claude = hide_claude,
  hide_all_sidebars = hide_all_sidebars,
  claude_prompt_empty = claude_prompt_empty,
  claude_visible = claude_visible,
  claude_cleanup = claude_cleanup,
  claude_state = function()
    return claude
  end,
}
