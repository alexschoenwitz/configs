vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system { 'git', 'clone', '--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath, }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	-- LSP Plugins
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'folke/neodev.nvim',
		},
	},

	{
		-- Autocompletion
		'hrsh7th/nvim-cmp',
		dependencies = {
			'L3MON4D3/LuaSnip',
			'saadparwaiz1/cmp_luasnip',
			'hrsh7th/cmp-nvim-lsp',
		},
	},

	-- Theme
	{ 'navarasu/onedark.nvim', opts = {} },
	{
		'folke/tokyonight.nvim',
		priority = 1000,
		config = function()
			vim.cmd.colorscheme 'onedark'
		end,
	},

	-- GUI
	{ 'itchyny/lightline.vim' },

	-- Fuzzy Finder (files, lsp, etc)
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'airblade/vim-rooter',
			-- requires 'make'.
			{
				'nvim-telescope/telescope-fzf-native.nvim',
				build = 'make',
				cond = function()
					return vim.fn.executable 'make' == 1
				end,
			},
		},
	},
	{
		-- Highlight, edit, and navigate code
		'nvim-treesitter/nvim-treesitter',
		dependencies = {
			'nvim-treesitter/nvim-treesitter-textobjects',
		},
		build = ':TSUpdate',
	},
	{
		"ray-x/go.nvim",
		dependencies = {
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("go").setup()
		end,
		event = { "CmdlineEnter" },
		ft = { "go", 'gomod' },
		build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
	},
}, {})

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
vim.keymap.set('n', '<leader>s', function() require('telescope.builtin').live_grep() end, { desc = '[S]earch' }) -- needs ripgrep [brew install ripgrep]
vim.keymap.set('n', '<leader>w', ':w<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>d', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', 'öd', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', 'äd', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })

-- Stop searching
vim.keymap.set({ 'n', 'v' }, '<C-h>', ':nohlsearch<cr>')

-- Search Results centered
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', '*', '*zz')
vim.keymap.set('n', '#', '#zz')
vim.keymap.set('n', 'g*', 'g*zz')


-- Lightline config
vim.g['lightline'] = {
	active = {
		left = { { 'mode', 'paste' },
			{ 'readonly', 'relativepath', 'modified' } },
		right = { { 'lineinfo' },
			{ 'percent' },
			{ 'fileencoding', 'filetype' }
		}
	}
}

-- [[ Configure Telescope ]]
require('telescope').setup {
	defaults = {
		file_ignore_patterns = { '.git', '.pb.go', '.pb.gw.go', '.openapi.yaml' },
		path_display = {
			smart = true,
		},
		layout_strategy = "vertical",
		layout_config = {
			width = 0.9,
			height = 0.9,
			prompt_position = "bottom",
		}
	},
	pickers = {
		find_files = {
			hidden = true,
		},
		live_grep = {
			additional_args = function()
				return { "--hidden" }
			end
		},
	},
}

vim.api.nvim_create_autocmd("User", {
	pattern = "TelescopePreviewerLoaded",
	callback = function()
		vim.wo.wrap = false
	end,
})

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')


-- [[ Configure Treesitter ]]
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
	require('nvim-treesitter.configs').setup {
		ensure_installed = { 'go', 'lua', 'bash' },
		sync_install = false,
		auto_install = true,
		ignore_install = { "" },
		highlight = { enable = true },
		indent = { enable = true },
		modules = {}
	}
end, 0)

-- [[ Configure LSP ]]
-- Format on save
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format{async=true}]]

--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = 'LSP: ' .. desc
		end

		vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
	end

	nmap('<leader>r', vim.lsp.buf.rename, '[R]e[n]ame')
	nmap('<leader>a', vim.lsp.buf.code_action, '[C]ode [A]ction')

	nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
	nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
	nmap('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
	nmap('gD', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
	nmap('<leader>e', function()
		require('telescope.builtin').lsp_dynamic_workspace_symbols {
			fname_width = 50,
			sorter = require("telescope").extensions.fzf.native_fzf_sorter({
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			})
		}
	end)

	nmap('<leader>g', require('telescope.builtin').git_status, '[G]it Status')

	-- See `:help K` for why this keymap
	nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
	nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
		vim.lsp.buf.format()
	end, { desc = 'Format current buffer with LSP' })
end

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Language servers
local servers = {
	bashls = {},
	bufls = {},
	dockerls = {},
	gopls = {},
	golangci_lint_ls = {},
	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
	yamlls = {},
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
	ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
	function(server_name)
		require('lspconfig')[server_name].setup {
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
			filetypes = (servers[server_name] or {}).filetypes,
		}
	end,
}

-- [[ Configure nvim-cmp ]]
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert {
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete {},
		['<CR>'] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
	},
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	},
}
