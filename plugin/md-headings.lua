-- Auto-execution bootstrap for md-headings plugin
-- This file ensures commands are registered even if setup() is not called

-- Prevent loading the plugin multiple times
if vim.g.loaded_md_headings then
  return
end
vim.g.loaded_md_headings = true

-- Initialize with default settings if setup hasn't been called
-- The user can still call setup() later to override these defaults
local md_headings = require("md-headings")

-- Register commands with default configuration
-- These will be available immediately when the plugin loads
vim.api.nvim_create_user_command("MarkdownNumberHeadings", function()
  md_headings.number_headings()
end, {
  desc = "Number markdown headings hierarchically",
})

vim.api.nvim_create_user_command("MarkdownRemoveNumbers", function()
  md_headings.remove_numbers()
end, {
  desc = "Remove numbers from markdown headings",
})

vim.api.nvim_create_user_command("MarkdownToggleNumbers", function()
  md_headings.toggle()
end, {
  desc = "Toggle md-headings plugin on/off",
})

vim.api.nvim_create_user_command("MarkdownTOC", function()
  md_headings.create_toc()
end, {
  desc = "Create table of contents at cursor",
})

vim.api.nvim_create_user_command("MarkdownTOCNumbered", function()
  md_headings.create_toc_numbered()
end, {
  desc = "Create numbered table of contents at cursor",
})
