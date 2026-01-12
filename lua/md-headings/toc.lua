-- Table of Contents generation for md-headings plugin
local M = {}

-- Convert heading text to GitHub-style anchor
-- Example: "1. Hello World!" -> "hello-world"
local function text_to_anchor(text)
  -- Use parser's strip_existing_numbers for consistency
  local parser = require("md-headings.parser")
  local cleaned = parser.strip_existing_numbers(text)

  -- Convert to lowercase
  cleaned = cleaned:lower()

  -- Remove special characters, keep alphanumeric, spaces, and hyphens
  cleaned = cleaned:gsub("[^%w%s%-_]", "")

  -- Replace spaces with hyphens
  cleaned = cleaned:gsub("%s+", "-")

  -- Remove leading/trailing hyphens
  cleaned = cleaned:gsub("^%-+", ""):gsub("%-+$", "")

  return cleaned
end

-- Generate a single TOC entry line
local function generate_toc_entry(heading, config)
  local indent_size = config.toc_indent_size or 2
  local use_numbers = config.toc_use_numbers or false

  -- Calculate indentation (level 1 = 0 spaces, level 2 = 2 spaces, etc.)
  local indent = string.rep(" ", (heading.level - 1) * indent_size)

  -- Get the text to display (with or without numbers)
  local display_text = heading.clean_content
  if use_numbers and heading.number then
    local separator = config.separator or "."
    display_text = heading.number .. separator .. " " .. heading.clean_content
  end

  -- Generate anchor from clean content
  local anchor = text_to_anchor(heading.clean_content)

  -- Create markdown link
  return string.format("%s- [%s](#%s)", indent, display_text, anchor)
end

-- Generate table of contents from headings
function M.generate_toc(headings, config)
  if not headings or #headings == 0 then
    return {}
  end

  local toc_lines = {}

  -- Add TOC header if configured
  if config.toc_add_header ~= false then
    table.insert(toc_lines, "## Table of Contents")
    table.insert(toc_lines, "")
  end

  -- Generate TOC entries
  for _, heading in ipairs(headings) do
    local entry = generate_toc_entry(heading, config)
    table.insert(toc_lines, entry)
  end

  -- Add blank line at the end
  table.insert(toc_lines, "")

  return toc_lines
end

-- Create TOC with current heading numbers
function M.create_toc_numbered(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local parser = require("md-headings.parser")
  local numbering = require("md-headings.numbering")
  local config_module = require("md-headings.config")
  local config = config_module.get()

  -- Parse headings
  local headings = parser.parse_buffer(bufnr, config)

  if not headings or #headings == 0 then
    vim.notify("md-headings: No headings found for TOC", vim.log.levels.INFO)
    return false
  end

  -- Generate numbers for headings
  local numbered_headings_raw = numbering.generate_numbers(headings, config)

  -- Convert to format needed for TOC (add number field to heading objects)
  local numbered_headings = {}
  for i, heading in ipairs(headings) do
    local new_heading = vim.deepcopy(heading)
    -- Extract number from numbered_headings_raw
    if numbered_headings_raw[i] then
      -- Parse number from formatted line (just the number part, separator is added separately)
      local formatted = numbered_headings_raw[i].formatted_line
      -- Match digits and dots (e.g., "1.2.3"), ensuring the last character is a digit (exclude trailing separator)
      local number = formatted:match("^#+%s+([%d%.]+[%d])")
      new_heading.number = number
    end
    table.insert(numbered_headings, new_heading)
  end

  -- Generate TOC with numbers
  local toc_config = vim.tbl_extend("force", config, { toc_use_numbers = true })
  local toc_lines = M.generate_toc(numbered_headings, toc_config)

  return M.insert_toc(bufnr, toc_lines, config, #numbered_headings)
end

-- Create TOC without numbers (plain headings)
function M.create_toc_plain(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local parser = require("md-headings.parser")
  local config_module = require("md-headings.config")
  local config = config_module.get()

  -- Parse headings (start from level 1 to include all)
  local temp_config = vim.tbl_extend("force", config, { start_level = 1 })
  local headings = parser.parse_buffer(bufnr, temp_config)

  if not headings or #headings == 0 then
    vim.notify("md-headings: No headings found for TOC", vim.log.levels.INFO)
    return false
  end

  -- Generate TOC without numbers
  local toc_config = vim.tbl_extend("force", config, { toc_use_numbers = false })
  local toc_lines = M.generate_toc(headings, toc_config)

  return M.insert_toc(bufnr, toc_lines, config, #headings)
end

-- Insert TOC at cursor position or top of file
function M.insert_toc(bufnr, toc_lines, _, entry_count)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if buffer is modifiable
  if not vim.api.nvim_get_option_value("modifiable", { buf = bufnr }) then
    vim.notify("md-headings: Buffer is not modifiable", vim.log.levels.ERROR)
    return false
  end

  -- Get cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1 -- Convert to 0-indexed

  -- Insert TOC at cursor position
  vim.api.nvim_buf_set_lines(bufnr, line, line, false, toc_lines)

  -- Use entry_count if provided, otherwise calculate from toc_lines
  local count = entry_count or #toc_lines
  vim.notify(
    string.format("md-headings: Created table of contents with %d %s", count, count == 1 and "entry" or "entries"),
    vim.log.levels.INFO
  )

  return true
end

return M
