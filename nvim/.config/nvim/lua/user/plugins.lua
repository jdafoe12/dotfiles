local lazy = {}

function lazy.install(path)
  if not vim.loop.fs_stat(path) then
    print('Installing lazy.nvim....')
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      path,
    })
  end
end
function lazy.setup(plugins)
  -- You can "comment out" the line below after lazy.nvim is installed
  lazy.install(lazy.path)

  vim.opt.rtp:prepend(lazy.path)
  require('lazy').setup(plugins, lazy.opts)
end

lazy.path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
lazy.opts = {}

lazy.setup({
	{'nvim-treesitter/nvim-treesitter'},
	{'HiPhish/rainbow-delimiters.nvim'},
	{'lukas-reineke/indent-blankline.nvim'},
	{'gbprod/nord.nvim'},
	{'nvim-lualine/lualine.nvim'},   -- Line at bottom of screen
	{'akinsho/toggleterm.nvim', version = "*", config = true},
})
