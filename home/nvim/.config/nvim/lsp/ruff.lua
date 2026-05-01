return {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "uv.lock", ".git" },
	settings = {
		ruff = {
			lint = { enable = true },
			format = { enable = true },
		},
	},
}
