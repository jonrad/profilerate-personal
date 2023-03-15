local path = vim.fn.expand('<sfile>:p:h')
vim.cmd('source ' .. path .. '/vimrc')
vim.cmd('luafile ' .. path .. '/kickstart.lua')
