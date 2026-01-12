-- Hierarchical numbering algorithm for md-headings plugin
local M = {}

-- Format a single heading line with number
function M.format_heading_line(heading, number, config)
  local hashes = string.rep("#", heading.level)
  local separator = config.separator or "."
  local add_space = config.add_space

  if add_space == nil then
    add_space = true
  end

  local space = add_space and " " or ""
  return string.format("%s %s%s%s%s", hashes, number, separator, space, heading.clean_content)
end

-- Generate hierarchical numbers for a list of headings
-- Uses a counter array approach for proper nesting
function M.generate_numbers(headings, config)
  if not headings or #headings == 0 then
    return {}
  end

  local counters = { 0, 0, 0, 0, 0, 0 } -- Support 6 heading levels
  local numbered_headings = {}
  local start_level = config and config.start_level or 1

  -- Track the minimum level we've seen to handle offset properly
  local min_level = 6
  for _, heading in ipairs(headings) do
    if heading.level < min_level then
      min_level = heading.level
    end
  end

  -- Adjust counter indices based on start_level
  -- If start_level is 2 and we see H2, it should be counted as level 1 in our counter
  local level_offset = min_level - 1

  for _, heading in ipairs(headings) do
    local level = heading.level
    local counter_index = level - level_offset

    -- Ensure counter_index is in valid range
    if counter_index < 1 then
      counter_index = 1
    end
    if counter_index > 6 then
      counter_index = 6
    end

    -- Increment counter at current level
    counters[counter_index] = counters[counter_index] + 1

    -- Reset all deeper level counters
    for i = counter_index + 1, 6 do
      counters[i] = 0
    end

    -- Build number string (e.g., "1.2.3")
    local number_parts = {}
    for i = 1, counter_index do
      table.insert(number_parts, tostring(counters[i]))
    end
    local number = table.concat(number_parts, ".")

    -- Format the heading line
    local formatted_line = M.format_heading_line(heading, number, config)

    table.insert(numbered_headings, {
      line_number = heading.line_number,
      formatted_line = formatted_line,
    })
  end

  return numbered_headings
end

-- Apply numbered headings to buffer
-- Modifies lines in reverse order to maintain line indices
function M.apply_to_buffer(bufnr, numbered_headings)
  if not numbered_headings or #numbered_headings == 0 then
    vim.notify("md-headings: No headings found to number", vim.log.levels.INFO)
    return false
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if buffer is modifiable
  if not vim.api.nvim_get_option_value("modifiable", { buf = bufnr }) then
    vim.notify("md-headings: Buffer is not modifiable", vim.log.levels.ERROR)
    return false
  end

  -- Process in reverse order to maintain line indices during updates
  for i = #numbered_headings, 1, -1 do
    local item = numbered_headings[i]
    local line_idx = item.line_number - 1 -- Convert to 0-indexed

    -- Replace the line
    vim.api.nvim_buf_set_lines(bufnr, line_idx, line_idx + 1, false, { item.formatted_line })
  end

  vim.notify(
    string.format("md-headings: Numbered %d heading%s", #numbered_headings, #numbered_headings == 1 and "" or "s"),
    vim.log.levels.INFO
  )

  return true
end

-- Remove numbers from all headings in buffer
function M.remove_numbers(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local parser = require("md-headings.parser")
  local config = require("md-headings.config").get()

  -- Parse buffer to find all headings (including those with numbers)
  local temp_config = vim.tbl_deep_extend("force", config, { start_level = 1 })
  local headings = parser.parse_buffer(bufnr, temp_config)

  if not headings or #headings == 0 then
    vim.notify("md-headings: No headings found", vim.log.levels.INFO)
    return false
  end

  -- Check if buffer is modifiable
  if not vim.api.nvim_get_option_value("modifiable", { buf = bufnr }) then
    vim.notify("md-headings: Buffer is not modifiable", vim.log.levels.ERROR)
    return false
  end

  -- Process in reverse order
  for i = #headings, 1, -1 do
    local heading = headings[i]
    local line_idx = heading.line_number - 1
    local hashes = string.rep("#", heading.level)
    local new_line = string.format("%s %s", hashes, heading.clean_content)

    vim.api.nvim_buf_set_lines(bufnr, line_idx, line_idx + 1, false, { new_line })
  end

  vim.notify(
    string.format("md-headings: Removed numbers from %d heading%s", #headings, #headings == 1 and "" or "s"),
    vim.log.levels.INFO
  )

  return true
end

return M
