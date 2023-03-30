local lsp_symbol = function(name, icon)
	vim.fn.sign_define("DiagnosticSign" .. name, { text = icon, texthl = "Diagnostic" .. name })
end

lsp_symbol("Error", "E")
lsp_symbol("Warn", "W")
lsp_symbol("Info" ,"I")
lsp_symbol("Hint", "H")
