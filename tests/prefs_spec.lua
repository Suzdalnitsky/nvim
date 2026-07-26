local prefs = require("prefs")

-- Make a throwaway window backed by a scratch buffer of the given filetype.
local function open_scratch(filetype)
  vim.cmd("vsplit")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = filetype
  vim.api.nvim_win_set_buf(win, buf)
  return win
end

describe("leader keys", function()
  it("are set to space", function()
    assert.are.equal(" ", vim.g.mapleader)
    assert.are.equal(" ", vim.g.maplocalleader)
  end)

  it("register the explorer keymaps", function()
    for _, lhs in ipairs({ "<leader>1", "<leader>2", "<leader>3" }) do
      assert.is_not.equal("", vim.fn.maparg(lhs, "n"))
    end
  end)

  it("register the telescope keymaps", function()
    for _, lhs in ipairs({ "<leader>n", "<leader>e", "<leader>f" }) do
      assert.is_not.equal("", vim.fn.maparg(lhs, "n"))
    end
  end)

  it("register the lazygit keymaps", function()
    for _, lhs in ipairs({ "<leader>k", "<leader>4" }) do
      assert.is_not.equal("", vim.fn.maparg(lhs, "n"))
    end
  end)

  it("register the Claude keymap", function()
    assert.is_not.equal("", vim.fn.maparg("<leader>5", "n"))
  end)
end)

describe("leave_explorer", function()
  before_each(function()
    vim.cmd("silent! only")
    vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, false))
  end)

  it("jumps from the explorer into the editor window", function()
    local editor = vim.api.nvim_get_current_win()
    local tree = open_scratch("neo-tree")
    vim.api.nvim_set_current_win(tree)

    prefs.leave_explorer()
    assert.are.equal(editor, vim.api.nvim_get_current_win())
  end)

  it("stays put when already in the editor window", function()
    local editor = vim.api.nvim_get_current_win()
    open_scratch("neo-tree")
    vim.api.nvim_set_current_win(editor)

    prefs.leave_explorer()
    assert.are.equal(editor, vim.api.nvim_get_current_win())
  end)
end)

describe("color theme", function()
  local function hex(s)
    return tonumber(s, 16)
  end

  it("declares a palette that the roles reference", function()
    assert.are.equal("#ffffff", prefs.palette.white)
    for _, r in ipairs(prefs.roles) do
      local key = r.fg or r.bg
      assert.is_not_nil(prefs.palette[key], "role " .. r.group .. " references unknown color " .. tostring(key))
    end
  end)

  it("uses a white background with black text", function()
    local n = vim.api.nvim_get_hl(0, { name = "Normal" })
    assert.are.equal(hex("ffffff"), n.bg)
    assert.are.equal(hex("000000"), n.fg)
  end)

  it("maps syntax roles to palette colors", function()
    assert.are.equal(hex("00008b"), vim.api.nvim_get_hl(0, { name = "Identifier" }).fg)
    assert.are.equal(hex("006400"), vim.api.nvim_get_hl(0, { name = "String" }).fg)
    assert.are.equal(hex("0000cd"), vim.api.nvim_get_hl(0, { name = "Number" }).fg)
    assert.are.equal(hex("800080"), vim.api.nvim_get_hl(0, { name = "Constant" }).fg)
  end)

  it("colors the git signs", function()
    assert.are.equal(hex("008000"), vim.api.nvim_get_hl(0, { name = "GitSignsAdd" }).fg)
    assert.are.equal(hex("0000cd"), vim.api.nvim_get_hl(0, { name = "GitSignsChange" }).fg)
    assert.are.equal(hex("af0000"), vim.api.nvim_get_hl(0, { name = "GitSignsDelete" }).fg)
  end)

  it("owns the core UI groups (selection/search/menu/statusline/diagnostics)", function()
    assert.are.equal(hex("cce6ff"), vim.api.nvim_get_hl(0, { name = "Visual" }).bg)
    assert.are.equal(hex("ffe680"), vim.api.nvim_get_hl(0, { name = "Search" }).bg)
    assert.are.equal(hex("ff8800"), vim.api.nvim_get_hl(0, { name = "IncSearch" }).bg)
    assert.are.equal(hex("e4e4e4"), vim.api.nvim_get_hl(0, { name = "Pmenu" }).bg)
    assert.are.equal(hex("00008b"), vim.api.nvim_get_hl(0, { name = "PmenuSel" }).bg)
    assert.are.equal(hex("e4e4e4"), vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg)
    assert.are.equal(hex("af0000"), vim.api.nvim_get_hl(0, { name = "DiagnosticError" }).fg)
    assert.are.equal(hex("0000cd"), vim.api.nvim_get_hl(0, { name = "DiagnosticInfo" }).fg)
  end)

  it("themes the telescope search UI dark, with a light readable preview", function()
    for _, g in ipairs({ "TelescopeNormal", "TelescopePromptNormal", "TelescopeResultsNormal" }) do
      local hl = vim.api.nvim_get_hl(0, { name = g })
      assert.are.equal(hex("1e1e1e"), hl.bg, g .. " should have the dark background")
      assert.are.equal(hex("d4d4d4"), hl.fg, g .. " should have the light foreground")
    end
    -- the preview stays light so previewed code is readable
    local prev = vim.api.nvim_get_hl(0, { name = "TelescopePreviewNormal" })
    assert.are.equal(hex("ffffff"), prev.bg)
    assert.are.equal(hex("000000"), prev.fg)
  end)

  it("themes the Claude sidebar as a plain white terminal (editor white/black)", function()
    local n = vim.api.nvim_get_hl(0, { name = "ClaudeNormal" })
    assert.are.equal(hex("ffffff"), n.bg, "Claude sidebar uses the plain white background")
    assert.are.equal(hex("000000"), n.fg, "Claude sidebar uses plain black text")
  end)

  it("renders keywords as plain black, not bold", function()
    for _, g in ipairs({ "Keyword", "Statement", "@keyword" }) do
      local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
      assert.are.equal(hex("000000"), hl.fg, g .. " should be black")
      assert.is_not_true(hl.bold, g .. " should not be bold")
    end
  end)

  it("stays a white light theme after another colorscheme loads", function()
    -- habamax is a dark builtin scheme; loading it flips &background and
    -- restyles Normal. Our ColorScheme hook must force both back.
    vim.cmd("colorscheme habamax")
    assert.are.equal("light", vim.o.background)
    local n = vim.api.nvim_get_hl(0, { name = "Normal" })
    assert.are.equal(hex("ffffff"), n.bg)
    assert.are.equal(hex("000000"), n.fg)
    -- the cursor colors must also survive the colorscheme (habamax sets its own)
    assert.are.equal(hex("000000"), vim.api.nvim_get_hl(0, { name = "Cursor" }).bg)
    assert.are.equal(hex("ff8800"), vim.api.nvim_get_hl(0, { name = "TermCursor" }).bg)
    -- and so must the core UI groups the theme now owns
    assert.are.equal(hex("cce6ff"), vim.api.nvim_get_hl(0, { name = "Visual" }).bg)
    assert.are.equal(hex("e4e4e4"), vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg)
  end)

  it("treats builtins and nil consistently with the palette", function()
    -- builtin functions (e.g. tostring) are identifiers -> deep blue
    assert.are.equal(hex("00008b"), vim.api.nvim_get_hl(0, { name = "@function.builtin", link = false }).fg)
    -- nil / booleans are constants -> purple
    assert.are.equal(hex("800080"), vim.api.nvim_get_hl(0, { name = "@constant.builtin", link = false }).fg)
  end)
end)

describe("claude sidebar", function()
  local stubdir, origin_path

  local function is_float(win)
    return vim.api.nvim_win_get_config(win).relative ~= ""
  end

  before_each(function()
    vim.cmd("silent! only")
    -- Reset to a plain editor buffer so first_editor_win has a real editor to
    -- find alongside the sidebar (a prior test may have left a scratch buffer).
    vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, false))
    origin_path = vim.env.PATH
    stubdir = vim.fn.tempname()
    vim.fn.mkdir(stubdir, "p")
    local stub = stubdir .. "/claude"
    -- A stub that stays alive, so "keeps running while hidden" is observable.
    vim.fn.writefile({ "#!/usr/bin/env bash", "sleep 30" }, stub)
    vim.fn.setfperm(stub, "rwxr-xr-x")
    vim.env.PATH = stubdir .. ":" .. origin_path
  end)

  after_each(function()
    prefs.claude_cleanup()
    vim.env.PATH = origin_path
    vim.fn.delete(stubdir, "rf")
  end)

  it("opens as a non-floating right sidebar about half the width, full height", function()
    prefs.toggle_claude()
    local win = prefs.claude_state().win
    assert.is_true(prefs.claude_visible())
    assert.is_false(is_float(win), "the sidebar is a real split, not a float")
    local want = math.floor(vim.o.columns * 0.5)
    assert.is_true(math.abs(vim.api.nvim_win_get_width(win) - want) <= 2,
      "sidebar is about half the editor width")
    assert.is_true(vim.api.nvim_win_get_height(win) >= vim.o.lines - 3,
      "sidebar spans the full editor height")
  end)

  it("hides without killing the session and re-shows the same buffer", function()
    prefs.toggle_claude() -- start + show
    local buf = prefs.claude_state().buf
    assert.is_not_nil(buf, "a session buffer is created")
    assert.is_true(vim.api.nvim_buf_is_valid(buf))
    assert.is_true(prefs.claude_visible())
    -- the Claude terminal is plain white, so the caret is the editor's black
    -- variant -- both the normal-mode block and the terminal-mode block
    assert.are.equal(tonumber("000000", 16), vim.api.nvim_get_hl(0, { name = "Cursor" }).bg,
      "black caret in the white Claude terminal")
    assert.are.equal(tonumber("000000", 16), vim.api.nvim_get_hl(0, { name = "TermCursor" }).bg,
      "black terminal-mode caret in the white Claude terminal")

    prefs.toggle_claude() -- hide (we're focused in it, so it closes)
    assert.is_false(prefs.claude_visible(), "sidebar is hidden")
    assert.are.equal(tonumber("000000", 16), vim.api.nvim_get_hl(0, { name = "Cursor" }).bg,
      "black caret in the editor after hiding")
    assert.are.equal(tonumber("ff8800", 16), vim.api.nvim_get_hl(0, { name = "TermCursor" }).bg,
      "terminal-mode caret resets to the dark-float orange default after leaving")
    assert.is_true(vim.api.nvim_buf_is_valid(buf), "session buffer survives hiding")
    assert.is_not_nil(prefs.claude_state().job, "job keeps running while hidden")
    assert.are.equal(buf, prefs.claude_state().buf, "same session is kept")

    prefs.toggle_claude() -- show again
    assert.is_true(prefs.claude_visible())
    assert.are.equal(buf, prefs.claude_state().buf, "re-shows the same session buffer")
  end)

  it("focuses the sidebar when it's open but unfocused (like neo-tree)", function()
    prefs.toggle_claude() -- open + focus
    local win = prefs.claude_state().win
    assert.are.equal(win, vim.api.nvim_get_current_win())

    local editor = prefs.first_editor_win()
    assert.is_not_nil(editor, "the editor window is found alongside the sidebar")
    vim.api.nvim_set_current_win(editor)
    assert.are_not.equal(win, vim.api.nvim_get_current_win())

    prefs.toggle_claude() -- open but unfocused -> focus it, don't hide
    assert.is_true(prefs.claude_visible(), "sidebar stays open")
    assert.are.equal(win, vim.api.nvim_get_current_win(), "focus moved into the sidebar")
  end)

  it("survives the single-editor enforcer (not folded like an editor window)", function()
    prefs.toggle_claude()
    local win = prefs.claude_state().win
    prefs.enforce_single_window()
    assert.is_true(prefs.claude_visible(), "sidebar not closed")
    assert.is_true(vim.api.nvim_win_is_valid(win), "sidebar window survives")
  end)

  it("hide_all_sidebars closes the Claude sidebar (session keeps running)", function()
    prefs.toggle_claude()
    assert.is_true(prefs.claude_visible())
    prefs.hide_all_sidebars()
    assert.is_false(prefs.claude_visible(), "Claude sidebar hidden")
    assert.is_not_nil(prefs.claude_state().job, "session keeps running while hidden")
  end)

  it("stays in sync when the sidebar is the last window (no duplicate pane)", function()
    prefs.toggle_claude() -- open (editor + Claude)
    local buf = prefs.claude_state().buf

    -- Close the editor window so the Claude sidebar is the only window. Hiding
    -- the last window fails (E444); hide must refuse rather than desync state
    -- (claude.win -> nil while the window is still open) into a second pane.
    vim.api.nvim_win_close(prefs.first_editor_win(), false)
    local win = prefs.claude_state().win
    vim.api.nvim_set_current_win(win)

    prefs.hide_claude()
    assert.is_true(prefs.claude_visible(), "cannot hide the last window; stays open")
    assert.are.equal(win, prefs.claude_state().win, "window state stays in sync")

    -- A later toggle must not spawn a second pane on the same session buffer.
    prefs.toggle_claude()
    local showing = 0
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(w) == buf then
        showing = showing + 1
      end
    end
    assert.are.equal(1, showing, "exactly one pane shows the Claude buffer")

    -- Restore a normal editor window so later specs see default window options
    -- (the sole-window Claude pane carries number=false).
    vim.cmd("silent! only")
    vim.wo.number = true
    vim.wo.relativenumber = true
    vim.wo.winhighlight = ""
  end)

  it("recovers instead of bricking if the sidebar split fails (narrow terminal)", function()
    local cols, wmw = vim.o.columns, vim.o.winminwidth
    -- Force `botright vsplit` to fail with E36 (not enough room for two windows).
    vim.o.winminwidth = 10
    vim.o.columns = 12

    local ok = pcall(prefs.toggle_claude)
    vim.o.columns = cols
    vim.o.winminwidth = wmw

    assert.is_true(ok, "a failed split must not throw out of the keymap")
    assert.is_false(prefs.claude_visible(), "no sidebar was opened")
    assert.is_nil(prefs.claude_state().buf, "the half-built session was cleaned up")
    assert.is_nil(prefs.claude_state().job, "no dangling job")

    -- With room restored the sidebar must start normally, not stay bricked.
    prefs.toggle_claude()
    assert.is_true(prefs.claude_visible(), "sidebar opens once the terminal has room again")
    assert.is_not_nil(prefs.claude_state().job, "the Claude job started on the retry")
  end)

  it("binds <leader>+number in the terminal but never touches <Esc>", function()
    prefs.toggle_claude()
    local buf = prefs.claude_state().buf
    -- Collect the buffer-local terminal-mode maps, normalizing <Space> -> " ".
    local have = {}
    for _, m in ipairs(vim.api.nvim_buf_get_keymap(buf, "t")) do
      have[(m.lhs:gsub("<[Ss]pace>", " "))] = true
    end
    -- The editor's <leader>+number keys work from inside Claude...
    for _, key in ipairs({ "1", "2", "3", "4", "5" }) do
      assert.is_true(have[" " .. key], "<leader>" .. key .. " is mapped in the Claude terminal")
    end
    -- ...but <Esc> is left alone, so every Escape reaches Claude.
    assert.is_nil(have["<Esc>"], "<Esc> must not be intercepted in the Claude terminal")
    assert.are.equal("", vim.fn.maparg("<Esc>", "t", false))
  end)

  -- claude_prompt_empty gates the terminal <leader>+digit maps: only an empty
  -- input runs the editor action; with text the <Space><digit> goes to Claude.
  -- Fixtures are lifted from real Claude Code screens (v2.1.212).
  it("treats a blank / placeholder input box as empty (editor action runs)", function()
    -- idle after a response; the transcript echo also starts with ❯, but the
    -- *last* ❯ line (the input box) is empty
    assert.is_true(prefs.claude_prompt_empty({
      "❯ reply with exactly: ok",
      "⏺ ok",
      "❯ ",
      "  ⏸ manual mode on · ? for shortcuts",
    }))
    -- streaming: input box empty, so the shortcut still fires
    assert.is_true(prefs.claude_prompt_empty({
      "✽ Zigzagging… ",
      "❯ ",
      "  ⏸ manual mode on · esc to interrupt",
    }))
    -- fresh session: the dimmed Try "..." placeholder is not real text
    assert.is_true(prefs.claude_prompt_empty({
      '❯ Try "write a test for plugins.lua"',
      "  ⏸ manual mode on · ? for shortcuts",
    }))
    -- real screens use a no-break space (U+00A0) after ❯ — byte-exact fixtures
    assert.is_true(prefs.claude_prompt_empty({ "❯\194\160", "  ⏸ manual mode on" }))
    assert.is_true(prefs.claude_prompt_empty({
      "❯\194\160Try \"edit plugins.lua to...\"",
      "  ⏸ manual mode on",
    }))
    -- no prompt line on screen at all
    assert.is_true(prefs.claude_prompt_empty({ "⏺ working…" }))
  end)

  it("treats a non-empty input box as not-empty (digit forwarded to Claude)", function()
    assert.is_false(prefs.claude_prompt_empty({
      "  ◉ xhigh · /effort",
      "❯ hello there",
      "  ⏸ manual mode on",
    }))
    -- typed text that itself contains a digit
    assert.is_false(prefs.claude_prompt_empty({ "❯ 5 apples" }))
  end)
end)

describe("cursor contrast", function()
  local function hex(s)
    return tonumber(s, 16)
  end
  local function cursor_bg()
    return vim.api.nvim_get_hl(0, { name = "Cursor" }).bg
  end

  before_each(function()
    vim.cmd("silent! only")
    vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, false))
  end)

  it("enables truecolor", function()
    assert.is_true(vim.o.termguicolors)
  end)

  it("attaches highlight groups to guicursor so the terminal cursor is recolored", function()
    -- Without a group per mode, Neovim never sends the cursor color (OSC 12)
    -- to the terminal and all the Cursor highlights would be dead code.
    assert.is_not_nil(vim.o.guicursor:find("block%-Cursor"), "normal-mode block needs the Cursor group")
    assert.is_not_nil(vim.o.guicursor:find("ver25%-Cursor"), "insert-mode bar needs the Cursor group")
    assert.is_not_nil(vim.o.guicursor:find("TermCursor"), "terminal mode needs the TermCursor group")
  end)

  it("uses an orange terminal-mode cursor (dark floats only)", function()
    local tc = vim.api.nvim_get_hl(0, { name = "TermCursor" })
    assert.are.equal(hex("ff8800"), tc.bg)
    assert.are.equal(hex("000000"), tc.fg)
  end)

  it("turns orange on entering a Telescope prompt and black again on leaving", function()
    local prompt = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, prompt)
    vim.bo[prompt].filetype = "TelescopePrompt" -- fires FileType -> orange caret
    assert.are.equal(hex("ff8800"), cursor_bg(), "orange caret on the dark prompt")

    vim.cmd("doautocmd BufLeave") -- leaving the prompt -> black editor caret
    assert.are.equal(hex("000000"), cursor_bg(), "black caret restored on leave")
  end)
end)

describe("focus highlighting", function()
  local function hex(s)
    return tonumber(s, 16)
  end

  before_each(function()
    vim.cmd("silent! only")
    vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, false))
    vim.wo.cursorline = false -- clean base (a prior test may have reused a tree window)
  end)

  it("defines focused and unfocused cursor-line groups", function()
    assert.are.equal(hex("cce6ff"), vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg)
    assert.are.equal(hex("e4e4e4"), vim.api.nvim_get_hl(0, { name = "CursorLineUnfocused" }).bg)
    assert.is_true(vim.api.nvim_get_hl(0, { name = "CursorLineNr" }).bold)
  end)

  it("dims the explorer when it is not focused", function()
    local editor = vim.api.nvim_get_current_win()
    local tree = open_scratch("neo-tree")
    vim.api.nvim_set_current_win(editor)

    prefs.refresh_focus()
    assert.is_not_nil(vim.wo[tree].winhighlight:match("CursorLineUnfocused"))

    vim.api.nvim_set_current_win(tree)
    prefs.refresh_focus()
    assert.is_nil(vim.wo[tree].winhighlight:match("CursorLineUnfocused"))
  end)

  it("leaves editor windows alone (no forced cursor line)", function()
    local editor = vim.api.nvim_get_current_win()
    open_scratch("neo-tree")
    vim.api.nvim_set_current_win(editor)

    prefs.refresh_focus()
    assert.is_false(vim.wo[editor].cursorline)
    assert.is_nil((vim.wo[editor].winhighlight or ""):match("CursorLineUnfocused"))
  end)

  it("dims the Claude terminal when it is not focused (grey, like the explorer)", function()
    local editor = vim.api.nvim_get_current_win()
    -- a stand-in for the Claude terminal: a scratch window carrying the flag
    local cwin = open_scratch("")
    vim.b[vim.api.nvim_win_get_buf(cwin)].claude_terminal = true
    vim.api.nvim_set_current_win(editor)

    prefs.refresh_focus()
    assert.is_true(vim.wo[cwin].cursorline, "focus dimming forces a cursor line")
    assert.is_not_nil(vim.wo[cwin].winhighlight:match("CursorLineUnfocused"),
      "unfocused Claude shows the dimmed grey cursor line")

    vim.api.nvim_set_current_win(cwin)
    prefs.refresh_focus()
    assert.is_nil(vim.wo[cwin].winhighlight:match("CursorLineUnfocused"),
      "focused Claude drops the dimming (blue cursor line)")
  end)
end)

describe("autocmd groups", function()
  it("registers every managed autocmd inside a cleared augroup", function()
    -- Each of these must live in a named group so re-sourcing prefs.lua clears
    -- the old handlers instead of stacking duplicates.
    for _, g in ipairs({
      "theme", "color_demo", "single_window", "focus_hl", "autosave", "final_newline",
      "cursor_contrast",
    }) do
      local ok, cmds = pcall(vim.api.nvim_get_autocmds, { group = g })
      assert.is_true(ok, "augroup " .. g .. " should exist")
      assert.is_true(#cmds > 0, "augroup " .. g .. " should have autocmds")
    end
  end)
end)

describe("line numbers", function()
  it("uses hybrid line numbers", function()
    assert.is_true(vim.opt.number:get())
    assert.is_true(vim.opt.relativenumber:get())
  end)
end)

describe("statusline", function()
  it("uses a single global statusline (no per-window bars on the sidebars)", function()
    assert.are.equal(3, vim.opt.laststatus:get())
  end)
end)

describe("whitespace display", function()
  it("shows tabs and trailing whitespace", function()
    assert.is_true(vim.opt.list:get())
    local lc = vim.opt.listchars:get()
    assert.is_not_nil(lc.tab)
    assert.is_not_nil(lc.trail)
  end)

  it("uses a 4-column tab width", function()
    assert.are.equal(4, vim.opt.tabstop:get())
    assert.are.equal(4, vim.opt.shiftwidth:get())
  end)
end)

describe("neo-tree plugin spec", function()
  local function neo_tree_spec()
    for _, spec in ipairs(require("plugins")) do
      if spec[1] == "nvim-neo-tree/neo-tree.nvim" then
        return spec
      end
    end
  end

  it("sets an explorer width of 55", function()
    local spec = neo_tree_spec()
    assert.is_not_nil(spec)
    assert.are.equal(55, spec.opts.window.width)
  end)
end)

describe("file_in_cwd", function()
  it("is false for an empty (unnamed buffer) path", function()
    assert.is_false(prefs.file_in_cwd(""))
  end)

  it("is true for a path inside the cwd", function()
    local inside = vim.fn.getcwd() .. "/some/nested/file.lua"
    assert.is_true(prefs.file_in_cwd(inside))
  end)

  it("is false for a path outside the cwd", function()
    assert.is_false(prefs.file_in_cwd("/definitely/not/here.txt"))
  end)
end)

describe("window helpers", function()
  before_each(function()
    vim.cmd("silent! only")
  end)

  it("find no explorer when none is open", function()
    assert.is_nil(prefs.explorer_win())
  end)

  it("treat the only normal window as the editor window", function()
    assert.are.equal(vim.api.nvim_get_current_win(), prefs.first_editor_win())
  end)

  it("locate a neo-tree window and skip it as the editor window", function()
    local editor = vim.api.nvim_get_current_win()
    local tree = open_scratch("neo-tree")

    assert.are.equal(tree, prefs.explorer_win())
    assert.are.equal(editor, prefs.first_editor_win())
  end)
end)

describe("single-editor policy", function()
  local function count()
    local editors, explorers = 0, 0
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative == "" then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "neo-tree" then
          explorers = explorers + 1
        else
          editors = editors + 1
        end
      end
    end
    return editors, explorers
  end

  before_each(function()
    vim.cmd("silent! only")
    -- Reset the base window to a plain editor buffer (a previous test may have
    -- left a neo-tree scratch buffer showing here).
    vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, false))
  end)

  it("blocks the split chords", function()
    for _, lhs in ipairs({ "<C-w>s", "<C-w>v", "<C-w>n" }) do
      assert.is_not.equal("", vim.fn.maparg(lhs, "n"))
    end
  end)

  it("blocks the new-tab chord", function()
    assert.is_not.equal("", vim.fn.maparg("<C-w>T", "n"))
  end)

  it("collapses extra tabs back to one", function()
    vim.cmd("tabnew")
    vim.cmd("tabnew")
    assert.is_true(#vim.api.nvim_list_tabpages() > 1)
    prefs.enforce_single_tab()
    assert.are.equal(1, #vim.api.nvim_list_tabpages())
  end)

  it("auto-collapses a tab opened programmatically", function()
    vim.cmd("tabnew") -- fires TabNew -> scheduled enforce_single_tab
    vim.wait(200, function()
      return #vim.api.nvim_list_tabpages() == 1
    end)
    assert.are.equal(1, #vim.api.nvim_list_tabpages())
  end)

  it("collapses a second editor window into one", function()
    open_scratch("")
    prefs.enforce_single_window()
    local editors = count()
    assert.are.equal(1, editors)
  end)

  it("leaves one editor + one explorer alone", function()
    open_scratch("neo-tree")
    prefs.enforce_single_window()
    local editors, explorers = count()
    assert.are.equal(1, editors)
    assert.are.equal(1, explorers)
  end)

  it("collapses a duplicate explorer window", function()
    open_scratch("neo-tree")
    open_scratch("neo-tree")
    prefs.enforce_single_window()
    local _, explorers = count()
    assert.are.equal(1, explorers)
  end)
end)

describe("autosave", function()
  local origin_cwd

  -- Make a fresh temp directory and cd into it; return the canonical path
  -- (from getcwd, so it matches what file_in_cwd computes).
  local function cd_temp()
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir, "p")
    vim.cmd("cd " .. vim.fn.fnameescape(dir))
    return vim.fn.getcwd()
  end

  local function cur_buf()
    return vim.api.nvim_get_current_buf()
  end

  before_each(function()
    origin_cwd = vim.fn.getcwd()
    vim.cmd("silent! %bwipeout!")
  end)

  after_each(function()
    vim.cmd("cd " .. vim.fn.fnameescape(origin_cwd))
  end)

  it("skips an unnamed buffer even when modified", function()
    vim.cmd("enew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "typed something" })
    assert.is_true(vim.bo.modified)
    assert.is_false(prefs.should_autosave(cur_buf()))
  end)

  it("skips a special (non-file) buffer", function()
    vim.cmd("enew")
    vim.bo.buftype = "nofile"
    assert.is_false(prefs.should_autosave(cur_buf()))
  end)

  it("skips an unmodified named buffer", function()
    local dir = cd_temp()
    local path = dir .. "/on-disk.txt"
    vim.fn.writefile({ "on disk" }, path)
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    assert.is_false(vim.bo.modified)
    assert.is_false(prefs.should_autosave(cur_buf()))
    vim.fn.delete(dir, "rf")
  end)

  it("skips a modified file outside the cwd", function()
    cd_temp() -- launch dir
    local outside = vim.fn.tempname() .. "-sdk-source.txt" -- a different temp path
    vim.cmd("edit " .. vim.fn.fnameescape(outside))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "do not touch" })
    assert.is_true(vim.bo.modified)
    assert.is_false(prefs.should_autosave(cur_buf()))
  end)

  it("adds a trailing newline on save (POSIX text file)", function()
    local path = vim.fn.tempname()
    local f = assert(io.open(path, "wb"))
    f:write("no final newline") -- file with no trailing newline
    f:close()

    vim.cmd("edit " .. vim.fn.fnameescape(path))
    vim.bo.fixendofline = false -- so only our BufWritePre can add the newline
    vim.cmd("write")

    local rf = assert(io.open(path, "rb"))
    local data = rf:read("*a")
    rf:close()
    assert.are.equal("\n", data:sub(-1))
    vim.fn.delete(path)
  end)

  it("warns once per failure episode and resets after a clean save", function()
    local dir = cd_temp()
    local sub = dir .. "/sub"
    vim.fn.mkdir(sub, "p")
    local path = sub .. "/note.txt"
    -- Opens cleanly (writable dir), so it passes should_autosave's checks:
    -- the buffer is a normal, writable, non-readonly file inside the cwd.
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "content" })
    assert.is_true(vim.bo.modified)
    assert.is_false(vim.bo.readonly)

    local notes = {}
    local orig_notify = vim.notify
    vim.notify = function(msg, level) notes[#notes + 1] = { msg = msg, level = level } end

    -- Remove the directory out from under the buffer: the write now fails at
    -- runtime even though the buffer looked saveable when it was opened.
    vim.fn.delete(sub, "rf")
    prefs.autosave()
    prefs.autosave() -- still failing, but must stay quiet (warn once)
    assert.are.equal(1, #notes, "should warn exactly once while failing")
    assert.are.equal(vim.log.levels.WARN, notes[1].level)
    assert.is_not_nil(notes[1].msg:match("Autosave failed"))

    -- Restore the directory: the next autosave saves cleanly and clears state.
    vim.fn.mkdir(sub, "p")
    prefs.autosave()
    assert.is_false(vim.bo.modified, "should save cleanly once the dir is back")
    assert.are.equal(1, #notes, "a clean save must not add a warning")

    -- A fresh failure episode warns again.
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "more" })
    vim.fn.delete(sub, "rf")
    prefs.autosave()
    assert.are.equal(2, #notes, "a new failure episode warns again")

    vim.notify = orig_notify
    vim.fn.delete(dir, "rf")
  end)

  it("forces endofline on a normal (non-binary) buffer before save", function()
    vim.cmd("enew")
    vim.bo.binary = false
    vim.bo.endofline = false
    vim.bo.fixendofline = false
    vim.cmd("doautocmd BufWritePre")
    assert.is_true(vim.bo.endofline)
    assert.is_true(vim.bo.fixendofline)
  end)

  it("leaves a binary buffer's end-of-line options untouched before save", function()
    vim.cmd("enew")
    vim.bo.binary = true
    vim.bo.endofline = false
    vim.bo.fixendofline = false
    vim.cmd("doautocmd BufWritePre")
    assert.is_false(vim.bo.endofline, "must not force endofline on a binary buffer")
    assert.is_false(vim.bo.fixendofline, "must not force fixendofline on a binary buffer")
    vim.bo.binary = false
  end)

  it("writes a modified named buffer inside the cwd to disk", function()
    local dir = cd_temp()
    local path = dir .. "/note.txt"
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello autosave" })
    assert.is_true(vim.bo.modified)

    prefs.autosave()

    assert.is_false(vim.bo.modified)
    assert.are.same({ "hello autosave" }, vim.fn.readfile(path))
    vim.fn.delete(dir, "rf")
  end)

  it("debounces a text change and flushes after the delay", function()
    local dir = cd_temp()
    local path = dir .. "/deb.txt"
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "typed" })
    assert.is_true(vim.bo.modified)

    vim.cmd("doautocmd TextChanged")
    assert.is_true(vim.bo.modified, "not written immediately — the write is debounced")

    vim.wait(1000, function()
      return not vim.bo.modified
    end)
    assert.is_false(vim.bo.modified, "flushed after the debounce window")
    assert.are.same({ "typed" }, vim.fn.readfile(path))
    vim.fn.delete(dir, "rf")
  end)

  it("saves immediately (no debounce) on a commit-point event", function()
    local dir = cd_temp()
    local path = dir .. "/imm.txt"
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "typed" })
    assert.is_true(vim.bo.modified)

    vim.cmd("doautocmd InsertLeave")
    assert.is_false(vim.bo.modified, "InsertLeave writes right away")
    assert.are.same({ "typed" }, vim.fn.readfile(path))
    vim.fn.delete(dir, "rf")
  end)
end)
