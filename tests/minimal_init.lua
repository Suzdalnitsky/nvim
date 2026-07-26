-- Minimal init used to run the test suite in a bare Neovim.
-- Puts this config and plenary.nvim on the runtimepath; nothing else.
local here = debug.getinfo(1, "S").source:sub(2)
local root = vim.fn.fnamemodify(here, ":h:h")
vim.opt.rtp:prepend(root .. "/nvim")

local plenary = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"
if not (vim.uv or vim.loop).fs_stat(plenary) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/nvim-lua/plenary.nvim.git", plenary,
  })
end
vim.opt.rtp:prepend(plenary)

vim.cmd("runtime plugin/plenary.vim")
