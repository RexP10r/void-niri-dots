return {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "uv.lock" },
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "off",
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,

				extraPaths = { "." },

				venvPath = ".",
				venv = ".venv",
			}
		}
	}
}
