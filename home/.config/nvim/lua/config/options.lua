local opt = vim.opt
local opt_global = vim.go

--------------------------
-- Local and Global (set)
--------------------------

-- Show number
opt.number = true
-- Encodings
opt.encoding = 'utf-8'
opt.fileencodings = 'utf-8,iso-2022-jp,euc-jp,sjis'
-- Split directions
opt.splitright = true
opt.splitbelow = true
-- Persistent undo
opt.undodir = vim.env.HOME .. '/.cache/nvim/undo'
opt.undofile = true
-- Clipboard (mac)
if jit.os == "OSX" then
  opt.clipboard = 'unnamed'
end
-- Do not hide quote of JSON
opt.conceallevel = 0
-- auto reload
opt.autoread = true
-- color
opt.pumblend = 20 -- Transparency
opt.termguicolors = true


----------------------
-- Global (setglobal)
----------------------

-- Indent
opt.smarttab = true
opt.expandtab = true
opt.tabstop = 2
opt.smartindent = true
opt.shiftwidth = 2
