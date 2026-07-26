# nvim

## Features

### Leader keys
Both `<leader>` and `<localleader>` are the **spacebar**.

### File explorer (neo-tree)
The [neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim) file explorer,
driven by `<leader>1`:

- **Closed** → opens the explorer. If your current file lives inside the current
  working directory, it reveals (jumps to) that file; otherwise it just opens
  and focuses the tree.
- **Open, and you're in it** → closes it.
- **Open, but you're elsewhere** → jumps focus into it.

The tree auto-refreshes when files change on disk (OS file watcher). Its width
is 55 columns (wider than neo-tree's default 40).

### Single-editor policy (no splits, no tabs)
There is always exactly **one** editing window (plus, optionally, the explorer),
in a single tab.

- The split chords `<C-w>s`, `<C-w>v`, `<C-w>n` (and their `<C-w><C-…>`
  variants), plus `<C-w>T` (move window to a new tab), are blocked and print a
  warning instead.
- The `:split`, `:vsplit`, `:new`, `:vnew` commands (short forms `:sp`, `:vs`,
  `:vsp`, `:vne`) and the tab commands `:tabnew`, `:tabedit`/`:tabe`,
  `:tabfind`/`:tabf` are blocked and print a warning.
- If a plugin or command opens a second editor window anyway, its buffer is
  folded into the main window and the extra window is closed automatically —
  the same goes for a duplicate explorer window. If a **tab** is opened
  programmatically, it's collapsed back to the first tab. Floating windows are
  left alone.

### Quit aliases
`:q`, `:q!`, and `:wq` quit the whole editor — they behave as `:qa`, `:qa!`,
and `:wqa`. With one window enforced, quitting always means quitting.

### Autosave
Buffers save themselves so you rarely need to type `:w`.

- **Triggers** immediately when you leave insert mode, lose window focus, or
  leave the buffer. Normal-mode text edits also save, but **debounced** (~300 ms)
  so a burst of edits (holding `x`, repeated `dd`, undo/redo) becomes one write
  instead of hammering the disk and the file watchers.
- **Only** for a normal, writable, **named** file that lives **inside the
  directory Neovim was launched in**. Special buffers, read-only buffers, new
  unnamed buffers, and files opened from outside the project (e.g. SDK/stdlib
  sources you jump into) are skipped — so you never accidentally overwrite a
  foreign file.
- If a write **fails** (permissions, disk full, the file's directory was removed,
  …) you get a one-time warning for that buffer telling you to save manually. It
  won't nag on every keystroke and resets once the buffer saves cleanly again.

### Final newline on save
- Every saved **text** file is written ending with a trailing newline (a proper
  POSIX text file), regardless of how it was originally loaded.
- **Binary** files (opened with `-b` / `:set binary`) are exempt — no newline is
  appended and their end-of-line options are left untouched, so their bytes are
  preserved exactly.

### Color theme
A light theme built from a named palette (declared first) that roles map onto.

- The background is **always white** (`#ffffff`): light mode, reapplied after
  any `:colorscheme` so nothing can override it.
- Syntax: identifiers (variable/function names, incl. builtins) deep blue,
  strings dark green, numbers blue, constants/booleans/`nil` purple, comments
  gray. Everything else (keywords, operators, punctuation) is plain black with
  no bold — only the palette's roles get color.
- Git signs: added green, changed blue, deleted red. Whitespace markers gray,
  cursor line light blue.
- The core UI groups are themed too, so a loaded `:colorscheme` can't leave them
  a half-dark mismatch: visual selection light blue, search light yellow (current
  match orange), the popup menu light gray (selected item navy), the statusline
  light gray, and diagnostics red/orange/blue/gray (error/warn/info/hint).
- Preview the colors by opening a file in `demos/` (`demo.lua`, `demo.swift`,
  `demo.java`) — each is a normal source file the theme highlights, with a
  header listing every palette color and a swatch of each, over a live syntax
  sample.

### Git gutter signs (gitsigns)
[gitsigns](https://github.com/lewis6991/gitsigns.nvim) marks added/changed/
deleted lines in the sign column: added/changed use `▋`, delete uses `▁`, and
top-delete uses `▔`. Change-delete and untracked keep gitsigns' defaults.

### Focus-aware highlighting
The **sidebars'** cursor line reflects focus, so it's obvious which pane has your
keystrokes. This applies to both the neo-tree explorer and the Claude terminal;
editor windows are left untouched.

- Sidebar focused: light-blue cursor line with a bold line number.
- Sidebar unfocused (you're editing): a dimmed gray cursor line.
- Applied per window via `winhighlight`, so each window's own highlights
  (neo-tree's, or Claude's white background) are preserved.

### Status line
A single **global** status line at the very bottom of the editor
(`laststatus=3`) rather than one per window — so the sidebars (neo-tree and
Claude) carry no status bar of their own.

### Line numbers
Hybrid line numbers: the current line shows its absolute number, every other
line shows its distance from the cursor (`number` + `relativenumber`).

### Whitespace & indentation
Tabs and trailing whitespace are always visible: tabs render as `--->`, trailing
spaces as `·`. Tab width is 4 columns (`tabstop` and `shiftwidth`).

### Fuzzy finder (telescope)
[telescope](https://github.com/nvim-telescope/telescope.nvim) (with the
fzf-native extension) provides find-files, recent-files, and live-grep pickers.

- Every picker first jumps you out of the explorer, so results open in the
  editor window.
- **Find files** and **live grep** start in insert mode; **recent files** opens
  in **normal mode**.
- **Live grep** remembers the text you last searched for during the session
  (it prefills the prompt; resets when you quit Neovim).
- **Find files** and **recent files** show **no preview** — each opens as a
  centered box half the screen wide and tall. (Live grep keeps the full-size
  picker with its preview.)
- The search UI (prompt + results) uses the same dark palette as the LazyGit
  float; the preview stays light so previewed code is readable.
- The cursor is **black in the editor and orange in the dark popups** (this
  prompt and the Claude / LazyGit terminals), for both the insert bar and the
  normal-mode block — a black cursor would vanish on the dark backgrounds.
  Neovim recolors the terminal's cursor on the fly (OSC 12, supported by
  Ghostty and most modern terminals) and restores the terminal's own cursor
  color on exit.
- In the prompt, `<Esc>` enters telescope's normal mode (press it again there
  to close), rather than closing immediately.

### LazyGit
[lazygit](https://github.com/jesseduffield/lazygit) in a floating terminal.

- Opens in a floating window sized to ~90% of the screen, with its own dark
  palette so it reads as a separate tool.
- `<leader>k` opens LazyGit; `<leader>4` opens it focused on the commit log.
- `<Esc>` at the top level quits lazygit and closes the float (via lazygit's
  `quitOnTopLevelReturn`, merged on top of your own lazygit config); `<Esc>`
  still works for lazygit's own navigation.
- If `lazygit` isn't on your `PATH`, you get a clear error with install
  instructions instead of a cryptic failure.

### Claude
[Claude Code](https://docs.claude.com/en/docs/claude-code) in a **persistent**
right-hand **sidebar** — a real split (**full height, half the editor width**),
not a float. It behaves exactly like the neo-tree explorer, driven by
`<leader>5`:

- **Closed** → opens the sidebar (starting Claude the first time) and focuses it.
- **Open, but you're elsewhere** → jumps focus into it (dropping straight into
  the terminal, ready to type) — it does **not** hide.
- **Open, and you're in it** → hides it. (Exception: if the sidebar is the
  **only** window, hiding is a no-op — the last window can't be closed — so it
  stays open; open another window first.)

Other behavior:

- Hiding never stops Claude — the process **keeps running** in a hidden buffer
  and reappears where you left it. The session ends only when Claude itself
  exits (e.g. you `/exit`), at which point the sidebar and buffer are torn down
  and the next `<leader>5` starts fresh.
- The sidebar counts as a **sidebar, not an editor window**: the single-editor
  policy leaves it alone (like the explorer), `<leader>2` skips it when focusing
  the main editor, its width is pinned (`winfixwidth`) so toggling the explorer
  doesn't resize it, and it shows no line numbers, sign column, or status bar of
  its own. Like the explorer, its **cursor line reflects focus** — light blue
  when Claude is focused, dimmed grey while you're editing elsewhere.
- **`<Esc>` is Claude's** — it is not intercepted at all, so every Escape
  (interrupt, cancel a dialog, clear the input, …) reaches Claude untouched. To
  hide the sidebar, use `<leader>5` or `<leader>3`.
- **`<leader>`+number works from inside the terminal** — the editor's
  `<leader>1`…`<leader>5` maps are rebound inside the Claude buffer (buffer-local,
  so the LazyGit float is unaffected), so you can drive the explorer, jump to the
  editor, hide sidebars, or open LazyGit without first leaving Claude's input.
  - Because `<leader>` is the **spacebar**, each of these fires **only when
    Claude's input box is empty**. If the prompt already has text, the literal
    `<Space>`+digit is forwarded to Claude instead — so typing e.g. `5 apples`
    still works. (Emptiness is read from Claude's own `❯` input line; the dimmed
    `Try "…"` placeholder of a fresh session counts as empty.)
- Rendered as a **plain white terminal** — the same white background and black
  text as the editor, deliberately unaffected by the rest of the color theme
  (no dark mode, no accent border). The caret is the editor's black one too
  (both the insert bar and the block), not the dark-popup orange the LazyGit
  float uses.
- If `claude` isn't on your `PATH`, you get a clear error with an install link
  instead of a cryptic failure.
- If the window is too narrow to open the half-width sidebar, you get a clear
  error and the session is **not** left half-started — the next `<leader>5`
  simply retries (rather than the sidebar becoming permanently unusable).

### Hide all sidebars
`<leader>3` hides **every** sidebar at once — both the neo-tree explorer and the
Claude sidebar — leaving just the editor. Hiding Claude this way keeps its
session running (same as `<leader>5`).

## Keymaps

All keymaps are normal-mode (leader is the spacebar) unless noted.

| Key | Action |
|---|---|
| `<leader>1` | Toggle file explorer (open + reveal current file / close / focus) |
| `<leader>2` | Focus the main editor window (the first non-sidebar window) |
| `<leader>3` | Hide all sidebars (explorer + Claude) |
| `<leader>n` | Find files |
| `<leader>e` | Recently opened files (opens in normal mode) |
| `<leader>f` | Live grep (remembers your last search) |
| `<leader>k` | Open LazyGit |
| `<leader>4` | Open LazyGit at the commit log |
| `<leader>5` | Toggle/focus the Claude sidebar (open + focus / focus / hide; persistent session, plain white) |
| `<leader>1`–`<leader>5` (inside the Claude terminal) | Same editor actions as above — but only when Claude's input box is empty; otherwise the `<Space>`+digit is typed into Claude |
| `<Esc>` (in the Claude sidebar) | Not intercepted — every Escape goes to Claude |
| `<C-w>s` / `<C-w>v` / `<C-w>n` (and `<C-w><C-…>`) / `<C-w>T` | **Blocked** — splits/tabs disabled |
| `:q` / `:q!` / `:wq` | Aliased to `:qa` / `:qa!` / `:wqa` |
| `:split` / `:vsplit` / `:new` / `:vnew` / `:tabnew` / `:tabedit` (+ short forms) | **Blocked**, prints a warning |
