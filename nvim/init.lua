-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Delete old swapfiles
vim.api.nvim_create_autocmd("SwapExists", {
	callback = function()
		local swapname = vim.v.swapname
		local afile = vim.fn.expand("<afile>:p")
		if vim.fn.getftime(afile) > vim.fn.getftime(swapname) then
			vim.v.swapchoice = "d"
		end
	end,
})

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.termguicolors = true

-- Indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.autoindent = true

-- Search Results centered
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")
vim.keymap.set("n", "g*", "g*zz")

vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

vim.keymap.set("n", "<leader>f", ":Format<CR>")
vim.keymap.set("n", "<leader>F", ":FormatWrite<CR>")
vim.keymap.set("n", "<leader>s", ":w<CR>")

vim.keymap.set("v", "y", "ygv<Esc>")

--
vim.keymap.set("n", "tv", ":lcd %:p:h<CR>:vs<CR><C-w><C-w>:set nonu<CR>:te<CR>i", { noremap = true, silent = true })
vim.keymap.set("n", "th", ":lcd %:p:h<CR>:sp<CR><C-w><C-w>:set nonu<CR>:te<CR>i", { noremap = true, silent = true })

vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 3
vim.g.netrw_altv = 1
vim.g.netrw_liststyle = 3
-- Hide files based on .gitignore and custom pattern
vim.g.netrw_list_hide = vim.fn["netrw_gitignore#Hide"]()
vim.g.netrw_list_hide = vim.g.netrw_list_hide .. ",\\(^\\|\\s\\s\\)\\zs\\.\\S\\+"

-- Use 'h' to go to the parent directory in netrw
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		vim.api.nvim_buf_set_keymap(0, "n", "h", "-^", { noremap = true, silent = true })
	end,
})
-- Use 'l' to open the directory or file under the cursor in netrw
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		vim.api.nvim_buf_set_keymap(0, "n", "l", "<CR>", { noremap = true, silent = true })
	end,
})

-- Statusline
vim.opt.laststatus = 2
vim.opt.statusline = "%f %y %m %r %= %-14.(%l,%c%V%) %P"

vim.wo.relativenumber = true -- Make line numbers default
vim.o.breakindent = true -- Enable break indent
vim.o.undofile = true -- Save undo history
vim.o.ignorecase = true -- Case-insensitive searching UNLESS \C or capital in search
vim.o.smartcase = true
vim.wo.signcolumn = "yes" -- Keep signcolumn on by default
vim.o.updatetime = 250 -- Decrease update time
vim.o.timeoutlen = 300
vim.o.completeopt = "menuone,noinsert,noselect" -- Set completeopt to have a better completion experience

local function ensure_deps_installed()
	if not (vim.fn.executable("stylua") ~= 0) then
		os.execute("brew install stylua")
	end
	if not (vim.fn.executable("sqlfmt") ~= 0) then
		os.execute("brew install sqlfmt")
	end
end
ensure_deps_installed()

-- Setup lazy.nvim
require("lazy").setup({

	{ "Mofiqul/vscode.nvim" },
	{ "tpope/vim-fugitive" },
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- Enable the following language servers
			require("lspconfig").gopls.setup({
				on_attach = function(client, bufnr)
					-- Set key bindings
					local function buf_set_keymap(...)
						vim.api.nvim_buf_set_keymap(bufnr, ...)
					end
					local opts = { noremap = true, silent = true }

					-- See `:help vim.lsp.*` for documentation on any of the below functions
					buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
					buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
					buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
					buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
					buf_set_keymap("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
					buf_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
					buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
					buf_set_keymap("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
					buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
					buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
					buf_set_keymap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
					buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
				end,
				flags = {
					debounce_text_changes = 150,
				},
			})
			require("lspconfig").sqlls.setup({
				on_attach = function(client, bufnr)
					-- Set key bindings
					local function buf_set_keymap(...)
						vim.api.nvim_buf_set_keymap(bufnr, ...)
					end
					local opts = { noremap = true, silent = true }

					buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
					buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
					buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
					buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
					buf_set_keymap("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
					buf_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
					buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
					buf_set_keymap("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
					buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
					buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
					buf_set_keymap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
					buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.format { async = true }<CR>", opts)
				end,
				flags = {
					debounce_text_changes = 150,
				},
				settings = {
					sqlls = {
						connections = {},
					},
				},
			})
		end,
	},
	{
		"alexghergh/nvim-tmux-navigation",
		config = function()
			local nvim_tmux_nav = require("nvim-tmux-navigation")
			vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
			vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
			vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
			vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
			vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
			vim.keymap.set("n", "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
		end,
	},
	{
		"mhartington/formatter.nvim",
		config = function()
			require("formatter").setup({
				filetype = {
					lua = {
						function()
							return {
								exe = "stylua",
								args = { "--search-parent-directories", "-" },
								stdin = true,
							}
						end,
					},
					sql = {
						function()
							return {
								exe = "sqlfmt",
								args = { "-" },
								stdin = true,
							}
						end,
					},
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "go" },
				highlight = {
					enable = true,
				},
			})
		end,
	},
})

-- Format after save
vim.api.nvim_create_augroup("__formatter__", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.lua",
	command = "FormatWrite",
})

local c = require("vscode.colors").get_colors()
require("vscode").setup({
	transparent = true,
	italic_comments = true,
	underline_links = true,
	disable_nvimtree_bg = true,
	group_overrides = {
		Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
	},
})

-- load the theme without affecting devicon colors.
vim.cmd.colorscheme("vscode")
