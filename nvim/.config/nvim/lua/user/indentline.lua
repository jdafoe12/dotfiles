local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
}
local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#BF616A" })     -- Nord11 (red)
    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#EBCB8B" })  -- Nord13 (yellow)
    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#81A1C1" })    -- Nord9 (blue)
    vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D08770" })  -- Nord12 (orange)
    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#A3BE8C" })   -- Nord14 (green)
    vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#B48EAD" })  -- Nord15 (purple)
    vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#88C0D0" })    -- Nord8 (cyan)
end)

require("ibl").setup { indent = { highlight = highlight } }
