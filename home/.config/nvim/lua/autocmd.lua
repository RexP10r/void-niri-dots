local ag = vim.api.nvim_create_augroup

local highlight_group = ag("YankHighLight", {clear = true})

vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({timeout = 170})
	end,
	group = highlight_group,
})
