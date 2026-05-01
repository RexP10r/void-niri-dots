return {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "uv.lock", ".git" },
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "off",
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly",
				venvPath=".venv",
				venv=".",
			}
		}
	}
}
