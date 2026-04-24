return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      javascript = { "eslint" },
      typescript = { "eslint" },
      rust = { "clippy" },
      c = { "clangtidy" },
      cpp = { "clangtidy" },
      go = { "golangci-lint" },
      cmake = { "cmakelint" },
    },
  },
}

