# Instructions

## Always keep README.md features in sync

Whenever you add, change, or remove a feature or keymap, update `README.md` in
the same change — its **Features** section and **Keymaps** table are the
user-facing record and must always match what the config actually does. Keep
`README.md` to features and keymaps only (no install/structure/test prose).

Document every notable behavior or quirk of a feature, not just the keymap —
e.g. a picker opening in normal mode, memory that resets on restart, a guard
that skips files outside the cwd. When a feature has more than one such
sub-behavior, document them as a **markdown list** under the feature (not a
prose paragraph). If you implement a non-obvious behavior, it goes in the
README's Features section AND you call it out explicitly in your reply to the
user. Do not leave such details unmentioned.

## Project layout

- `nvim/` — the installable config (copied verbatim to `~/.config/nvim` by
  `install.sh`).
  - `nvim/init.lua` — loads `prefs`, then boots lazy.nvim.
  - `nvim/lua/prefs.lua` — the single config file: all options, keymaps, and
    features live here. It returns its internal helpers so tests can reach them.
  - `nvim/lua/plugins.lua` — plugin specs.
  - `nvim/lua/config/lazy.lua` — bootstraps lazy.nvim (plugin management only).
  - `nvim/lazy-lock.json` — pinned plugin commits. Do not hand-edit; regenerate
    with `:Lazy update`/`restore`.
- `tests/` — plenary test suite; run with `./test.sh`.

## Working rules

- Add a test in `tests/prefs_spec.lua` for each new feature, and run `./test.sh`
  before considering a change done.
