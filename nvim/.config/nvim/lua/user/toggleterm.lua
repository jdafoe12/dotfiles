require('toggleterm').setup({
	open_mapping = '<C-t>',
	direction = 'horizontal',
	shade_terminals = false,
	shell = zsh,
	float_opts = {
		border = 'curved',
		winblend = 3,
		highlights = {
			border = "Normal",
			background = "Normal",
		}
	}
})
