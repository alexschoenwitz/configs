vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.wo.relativenumber = true                    -- Make line numbers default
vim.o.breakindent = true                        -- Enable break indent
vim.o.undofile = true                           -- Save undo history
vim.o.ignorecase = true                         -- Case-insensitive searching UNLESS \C or capital in search
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'                       -- Keep signcolumn on by default
vim.o.updatetime = 250                          -- Decrease update time
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noinsert,noselect' -- Set completeopt to have a better completion experience

-- [[ Keymaps ]]
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set({ 'v' }, 'y', 'y`]', { silent = true })
vim.keymap.set({ 'n', 'v' }, 'p', 'p`]', { silent = true })

vim.keymap.set('n', '<leader><leader>', '<c-^>', { desc = 'Toggle between buffers' })
vim.keymap.set('n', '<left>', ':bp<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<right>', ' :bn<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>,', ':set invlist<cr>', { desc = 'Show/hide hidden characters' })
vim.keymap.set('n', '<leader>o', ':e <C-R>=expand("%:p:h") . "/" <CR>',
	{ desc = 'Open new file in same directory as current file' })

-- Stop searching
vim.keymap.set({ 'n', 'v' }, '<C-h>', ':nohlsearch<cr>')

-- Search Results centered
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', '*', '*zz')
vim.keymap.set('n', '#', '#zz')
vim.keymap.set('n', 'g*', 'g*zz')