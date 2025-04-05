-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Indentation
opt.expandtab = true      -- Use spaces instead of tabs
opt.shiftwidth = 4        -- Number of spaces per indentation level
opt.tabstop = 4           -- Number of spaces a tab counts for
opt.softtabstop = 4       -- Consistent backspacing

-- UI Tweaks
opt.number = true         -- Show line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true     -- Highlight the current line
opt.termguicolors = true  -- Enable true colors
opt.signcolumn = "yes"    -- Always show sign column to prevent shifting

-- Search
opt.ignorecase = true     -- Case-insensitive search
opt.smartcase = true      -- Case-sensitive if uppercase letters are used
opt.incsearch = true      -- Incremental search
opt.hlsearch = true       -- Highlight search results

-- Performance
opt.updatetime = 300      -- Faster completion
opt.timeoutlen = 400      -- Faster key timeout

-- Wrapping & Scrolling
opt.wrap = false          -- Disable line wrapping
opt.scrolloff = 8         -- Keep cursor centered while scrolling
opt.sidescrolloff = 8     -- Keep cursor centered horizontally
