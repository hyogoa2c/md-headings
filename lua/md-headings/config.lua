-- Configuration management for md-headings plugin
local M = {}

-- Default configuration
local defaults = {
  -- Enable/disable the plugin
  enabled = true,

  -- Number separator: "." or ")"
  separator = ".",

  -- Add space between number and heading text
  add_space = true,

  -- Start numbering from this level (1-6)
  -- Set to 2 to skip H1 headings
  start_level = 1,

  -- Auto-number on save (future feature)
  auto_number_on_save = false,

  -- Skip headings that match certain patterns
  skip_patterns = {},

  -- Table of Contents settings
  -- Add "Table of Contents" header to TOC
  toc_add_header = true,

  -- Indentation size for TOC entries (spaces per level)
  toc_indent_size = 2,

  -- Use numbers in TOC (set by commands, not user config)
  toc_use_numbers = false,
}

-- Current configuration
local config = vim.deepcopy(defaults)

-- Merge user configuration with defaults
function M.set(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("force", config, opts)

  -- Validate configuration
  M.validate()
end

-- Get current configuration
function M.get()
  return config
end

-- Reset to defaults
function M.reset()
  config = vim.deepcopy(defaults)
end

-- Validate configuration values
function M.validate()
  -- Check start_level is in valid range
  if config.start_level < 1 or config.start_level > 6 then
    vim.notify(
      "md-headings: start_level must be between 1 and 6, using default (1)",
      vim.log.levels.WARN
    )
    config.start_level = 1
  end

  -- Check separator is valid
  if config.separator ~= "." and config.separator ~= ")" then
    vim.notify(
      'md-headings: separator must be "." or ")", using default (".")',
      vim.log.levels.WARN
    )
    config.separator = "."
  end

  -- Ensure skip_patterns is a table
  if type(config.skip_patterns) ~= "table" then
    vim.notify(
      "md-headings: skip_patterns must be a table, using default ({})",
      vim.log.levels.WARN
    )
    config.skip_patterns = {}
  end
end

return M
