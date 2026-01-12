-- Main module for md-headings plugin
-- Provides hierarchical numbering for markdown headings

local M = {}

-- Check if buffer is a markdown file
local function is_markdown_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  return filetype == "markdown" or filetype == "md"
end

-- Number all headings in the current buffer
function M.number_headings(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if it's a markdown buffer
  if not is_markdown_buffer(bufnr) then
    vim.notify("md-headings: Not a markdown buffer", vim.log.levels.WARN)
    return false
  end

  local config = require("md-headings.config").get()

  -- Check if plugin is enabled
  if not config.enabled then
    vim.notify("md-headings: Plugin is disabled", vim.log.levels.WARN)
    return false
  end

  local parser = require("md-headings.parser")
  local numbering = require("md-headings.numbering")

  -- Parse buffer to find headings
  local headings = parser.parse_buffer(bufnr, config)

  if not headings or #headings == 0 then
    vim.notify("md-headings: No headings found to number", vim.log.levels.INFO)
    return false
  end

  -- Generate hierarchical numbers
  local numbered_headings = numbering.generate_numbers(headings, config)

  -- Apply to buffer
  return numbering.apply_to_buffer(bufnr, numbered_headings)
end

-- Remove numbers from all headings in the current buffer
function M.remove_numbers(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if it's a markdown buffer
  if not is_markdown_buffer(bufnr) then
    vim.notify("md-headings: Not a markdown buffer", vim.log.levels.WARN)
    return false
  end

  local numbering = require("md-headings.numbering")
  return numbering.remove_numbers(bufnr)
end

-- Toggle numbering on/off
function M.toggle()
  local config = require("md-headings.config")
  local current_config = config.get()
  current_config.enabled = not current_config.enabled
  config.set(current_config)

  local status = current_config.enabled and "enabled" or "disabled"
  vim.notify("md-headings: Plugin " .. status, vim.log.levels.INFO)
end

-- Create table of contents at cursor position (plain, no numbers)
function M.create_toc(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if it's a markdown buffer
  if not is_markdown_buffer(bufnr) then
    vim.notify("md-headings: Not a markdown buffer", vim.log.levels.WARN)
    return false
  end

  local toc = require("md-headings.toc")
  return toc.create_toc_plain(bufnr)
end

-- Create table of contents with numbers at cursor position
function M.create_toc_numbered(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if it's a markdown buffer
  if not is_markdown_buffer(bufnr) then
    vim.notify("md-headings: Not a markdown buffer", vim.log.levels.WARN)
    return false
  end

  local toc = require("md-headings.toc")
  return toc.create_toc_numbered(bufnr)
end

-- Setup function to initialize the plugin
function M.setup(opts)
  opts = opts or {}

  -- Set configuration
  local config = require("md-headings.config")
  config.set(opts)

  local user_config = config.get()

  -- Note: Commands are registered in plugin/md-headings.lua to avoid duplication
  -- This setup function only handles configuration and autocmds

  -- Setup auto-numbering on save if enabled
  if user_config.auto_number_on_save then
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.md", "*.markdown" },
      callback = function(args)
        -- Use buffer from autocmd args for correct context
        local bufnr = args.buf
        if user_config.enabled and is_markdown_buffer(bufnr) then
          M.number_headings(bufnr)
        end
      end,
      desc = "Auto-number markdown headings on save",
    })
  end
end

return M
