return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      html = { "prettier" },
      json = { "prettier" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      rust = { "rustfmt" },
      c = { "clang-format" },
      cpp = { "clang-format" },
      go = { "gofmt" },
      zig = { "zigfmt" },
      lua = { "stylua" },
    },
  },
}

