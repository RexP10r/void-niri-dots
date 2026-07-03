print("hello")

require("plugins")
require("config")
require("keymap")
require("lsp")
require("autocmd")
require("nvim-autopairs")

vim.o.background = "dark"

-- Automatically load the colorscheme based on your bash script's state
local state_file = io.open(vim.fn.expand("~/.cache/theme-sync-state"), "r")
local current_theme = "tokyonight" -- default fallback

if state_file then
    current_theme = state_file:read("*l")
    state_file:close()
end

-- Mapping 
local theme_map = {
    everforest = "everforest",
    gruvbox = "gruvbox",
    nord = "nord",
    ["tokyo-night"] = "tokyonight",
    random = "tokyonight", -- fallback for 'random'
}

local colorscheme = theme_map[current_theme] or "tokyonight"
vim.cmd.colorscheme(colorscheme)
