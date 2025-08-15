return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "rust-analyzer", "clangd",
      "gopls", "zls", "cmake-language-server"
    },
  },
}

