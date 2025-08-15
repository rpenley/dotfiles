return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "html", "json", "javascript", "typescript", "rust", "c", "cpp",
      "go", "zig", "cmake"
    },
    highlight = { enable = true },
    indent = { enable = true },
  },
}

