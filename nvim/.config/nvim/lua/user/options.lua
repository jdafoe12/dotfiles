-- :help options

local options = {

	clipboard   = "unnamedplus", -- Allows system clipboard access in neovim
	number      = true,          -- Shows line number in the gutter
	mouse       = 'a',           -- Enables mouse in all modes
	ignorecase  = false,         -- Neovim is case sensitive
	hlsearch    = false,         -- Disables highlighting the results of previous search
	wrap        = true,          -- Enables wrapping long lines
	breakindent = true,          -- Preserves the indentation of a virtual line
	tabstop     = 4,             -- The amount of space a tab can occupy
	shiftwidth  = 4,             -- The amount of space to indent a line
	expandtab   = false,         -- Tels neovim to not convert tab to spaces
	splitbelow  = true,          -- Force all horizontal splits to go below current window
	splitright  = true,          -- Force all vertical splits to go above current window
	cursorline  = true,          -- Highlight the current line
	autoindent  = true,          -- Apply indentation of current line to next
	smartindent = true,          -- Smarter indentation for C like syntax
	history     = 10000,         -- Remember N lines 
	showmatch   = true           -- Highlight matching parenthesis

}

for k, v in pairs(options) do
	vim.opt[k] = v
end
