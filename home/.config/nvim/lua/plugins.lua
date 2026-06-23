_G.nvim_start_time = vim.uv.hrtime()

vim.pack.add({
	{ src = "https://github.com/folke/tokyonight.nvim" },
})

require("tokyonight").setup({})


vim.pack.add({
	{ src = "https://github.com/mason-org/mason.nvim" },
})

require("mason").setup({})


vim.pack.add({
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
})

require("lualine").setup({})


vim.pack.add({
	"https://github.com/ibhagwan/fzf-lua",
})

local actions = require("fzf-lua.actions")
require("fzf-lua").setup({
	winopts = { backdrop = 85 },
	keymap = {
		builtin = {
			["<C-f>"] = "preview-page-down",
			["<C-b>"] = "preview-page-up",
			["<C-p>"] = "toggle-preview",
		},
		fzf = {
			["ctrl-a"] = "toggle-all",
			["ctrl-t"] = "first",
			["ctrl-g"] = "last",
			["ctrl-d"] = "half-page-down",
			["ctrl-u"] = "half-page-up",
		}
	},
	actions = {
		files = {
			["ctrl-q"] = actions.file_sel_to_qf,
			["ctrl-n"] = actions.toggle_ignore,
			["ctrl-h"] = actions.toggle_hidden,
			["enter"] = actions.file_edit_or_qf,
		}
	}
})

vim.pack.add({
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("^1")
	},
})

require("blink.cmp").setup({
	fuzzy = { implementation = "prefer_rust_with_warning" },
	signature = { enabled = true },
	keymap = {
		preset = "default",
		["<C-space>"] = {},
		["<C-p>"] = {},
		["<Tab>"] = {},
		["<S-Tab>"] = {},
		["<C-y>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-n>"] = { "select_and_accept" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-b>"] = { "scroll_documentation_down", "fallback" },
		["<C-f>"] = { "scroll_documentation_up", "fallback" },
		["<C-l>"] = { "snippet_forward", "fallback" },
		["<C-h>"] = { "snippet_backward", "fallback" },
	},
	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "normal",
	},
	completion = {
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
		}
	},
	cmdline = {
		keymap = {
			preset = "inherit",
			["<CR>"] = { "accept_and_enter", "fallback" },
		},
	},
	sources = { default = { "lsp" } }
})

vim.pack.add({
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },
	-- dependencies
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
})

require("neo-tree").setup({})

vim.pack.add({
	{ src = "https://github.com/windwp/nvim-autopairs" }
})

require("nvim-autopairs").setup({
	check_ts = true,
})

vim.pack.add({
	'https://github.com/nvim-treesitter/nvim-treesitter',
	'https://github.com/nvim-mini/mini.nvim',
	'https://github.com/nvim-mini/mini.icons',
	'https://github.com/nvim-tree/nvim-web-devicons',
	'https://github.com/MeanderingProgrammer/render-markdown.nvim',
})
require('render-markdown').setup({
	completions = { lsp = { enabled = true } },
})

vim.pack.add({
	{ src = "https://github.com/sudo-tee/opencode.nvim" },
})

require("opencode").setup({})

vim.pack.add({
	{ src = "https://github.com/nanozuki/tabby.nvim" },
})
require('tabby').setup({})


vim.pack.add({
	{ src = "https://github.com/rcarriga/nvim-notify" },
	{ src = "https://github.com/folke/noice.nvim" },
})
require("noice").setup({
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
	presets = {
		bottom_search = true,
		command_palette = true,
		long_message_to_split = true,
		lsp_doc_border = true,
	},
})
vim.opt.termguicolors = true


vim.pack.add({
	{ src = "https://github.com/numToStr/Comment.nvim" },
})
require('Comment').setup({
})
vim.pack.add({
	{ src = "https://github.com/nvimdev/dashboard-nvim" },
})

require("dashboard").setup({
	theme = "doom",
	config = {
		vertical_center = true,
		header = {
			"███████╗██╗███╗   ██╗ ██████╗ ███████╗██████╗ ██╗   ██╗██╗███╗   ███╗",
			"██╔════╝██║████╗  ██║██╔════╝ ██╔════╝██╔══██╗██║   ██║██║████╗ ████║",
			"█████╗  ██║██╔██╗ ██║██║  ███╗█████╗  ██████╔╝██║   ██║██║██╔████╔██║",
			"██╔══╝  ██║██║╚██╗██║██║   ██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██║██║╚██╔╝██║",
			"██║     ██║██║ ╚████║╚██████╔╝███████╗██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║",
			"╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
		},

		center = {
			{
				icon = " ",
				desc = "New File",
				action = "ene | startinsert",
				key = "n",
			},
			{
				icon = " ",
				desc = "Find File",
				action = "FzfLua files",
				key = "f",
			},
			{
				icon = " ",
				desc = "Find Text",
				action = "FzfLua live_grep",
				key = "g",
			},
			{
				icon = " ",
				desc = "File Explorer",
				action = "Neotree toggle",
				key = "e",
			},
			{
				icon = " ",
				desc = "Configure",
				action = "edit ~/.config/nvim",
				key = "c",
			},
			{
				icon = " ",
				desc = "Quit",
				action = "qa",
				key = "q",
			},
		},
		footer = function()
			local end_time = vim.uv.hrtime()
			local total_ms = (end_time - (_G.nvim_start_time or end_time)) / 1000000
			return { string.format("Loaded in %.2f ms", total_ms) }
		end,
	},
})
