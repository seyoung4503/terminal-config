return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gm", "<cmd>Neogit<cr>", desc = "Neogit" },
    },
    opts = {
      graph_style = "unicode",
      integrations = { diffview = true },
    },
  },
}
