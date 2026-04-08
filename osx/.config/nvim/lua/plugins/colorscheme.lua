return {
  "stereoabuse/death-metal-theme-neovim",
  lazy = false,
  priority = 1000,
  config = function()
    require("death-metal").setup({
      theme = "death", -- Change to: at-the-gates, autopsy, bolt-thrower, cannibal-corpse, carcass, dismember, entombed, morbid-angel
      variant = "dark",
      colored_docstrings = true,
      code_style = {
        comments = "italic",
      },
    })
    require("death-metal").load()
  end,
}
