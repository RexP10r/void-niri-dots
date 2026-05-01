vim.lsp.enable({
	"rust-analyzer",
	"lua_ls",
--	"ruff",
	"pylsp",
	"basedpyright",
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function(args)
    vim.lsp.buf.format({ async = false, bufnr = args.buf, name = "ruff" })
  end,
})

vim.diagnostic.config({ virtual_text = true })

