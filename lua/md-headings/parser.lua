-- Markdown heading parser for md-headings plugin
local M = {}

-- Check if we're inside a code block at a given line index
-- Tracks ``` delimiters to determine code block state
local function is_in_code_block(lines, line_index)
  local in_block = false
  for i = 1, line_index - 1 do
    if lines[i]:match("^```") then
      in_block = not in_block
    end
  end
  return in_block
end

-- Strip existing numbers from heading content
-- Matches patterns like: "1.", "1.1.", "1.1.1.", "1)", "1.1)", etc.
function M.strip_existing_numbers(content)
  if not content then
    return ""
  end

  -- Match entire hierarchical number sequence at start
  -- Pattern: optional space + leading digit + (digits/dots/parens) + space
  -- This matches: "1.2.3 ", "1) ", "2.2.3) ", etc., but avoids stripping non-digit sequences like "..." or ")"
  local cleaned = content:gsub("^%s*%d[%d%.%)]*%s+", "")

  -- If nothing was removed, try without trailing space requirement
  -- This handles cases where number ends the string
  if cleaned == content then
    cleaned = content:gsub("^%s*%d[%d%.%)]*", "")
  end

  -- Trim any remaining leading/trailing whitespace
  cleaned = cleaned:match("^%s*(.-)%s*$") or ""

  return cleaned
end

-- Detect if a line is an ATX-style heading
-- Returns heading info if it's a heading, nil otherwise
function M.detect_heading(line, line_num, lines)
  if not line then
    return nil
  end

  -- Check if we're in a code block
  if is_in_code_block(lines, line_num) then
    return nil
  end

  -- Match ATX-style headings: ^(#+)\s+(.+)$
  -- Note: Lua patterns don't support {n,m} syntax, so we use + and check length
  local hashes, content = line:match("^(#+)%s+(.+)$")

  if not hashes or not content then
    return nil
  end

  local level = #hashes

  -- Validate heading level upper bound (1-6)
  if level > 6 then
    return nil
  end
  local stripped_content = M.strip_existing_numbers(content)

  -- Skip empty headings (headings with no content after stripping)
  if stripped_content == "" then
    return nil
  end

  return {
    level = level,
    original_content = content,
    clean_content = stripped_content,
    line_number = line_num,
  }
end

-- Parse entire buffer and extract all headings
function M.parse_buffer(bufnr, config)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Get all lines from buffer (0-indexed API, but we'll use 1-indexed internally)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local headings = {}
  local start_level = config and config.start_level or 1
  local skip_patterns = config and config.skip_patterns or {}

  -- Parse each line
  for i, line in ipairs(lines) do
    local heading = M.detect_heading(line, i, lines)

    if heading then
      -- Skip if heading level is below start_level
      if heading.level >= start_level then
        -- Check if heading matches any skip patterns
        local should_skip = false
        for _, pattern in ipairs(skip_patterns) do
          if heading.clean_content:match(pattern) then
            should_skip = true
            break
          end
        end

        if not should_skip then
          table.insert(headings, heading)
        end
      end
    end
  end

  return headings
end

return M
