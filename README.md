# md-headings.nvim

A modern Neovim plugin for hierarchical markdown heading numbering.

## Features

- Hierarchical numbering (1., 1.1, 1.1.1, etc.)
- Table of contents generation (with or without numbers)
- Automatically removes existing numbers before renumbering
- Configurable separator and formatting options
- Respects markdown code blocks
- Commands for numbering, removing numbers, and toggling
- Lazy-loading support for optimal performance
- Written in pure Lua for modern Neovim

## Installation

### lazy.nvim (recommended)

```lua
{
  "hyogoa2c/md-headings",
  ft = "markdown",  -- Lazy load on markdown files
  config = function()
    require("md-headings").setup({
      -- Optional: customize configuration
      separator = ".",
      add_space = true,
    })
  end,
  keys = {
    { "<leader>mn", ":MarkdownNumberHeadings<CR>", desc = "Number markdown headings" },
    { "<leader>mr", ":MarkdownRemoveNumbers<CR>", desc = "Remove heading numbers" },
    { "<leader>mt", ":MarkdownTOC<CR>", desc = "Create table of contents" },
    { "<leader>mT", ":MarkdownTOCNumbered<CR>", desc = "Create numbered TOC" },
  },
}
```

### packer.nvim

```lua
use {
  "hyogoa2c/md-headings",
  ft = "markdown",
  config = function()
    require("md-headings").setup()
  end
}
```

### vim-plug

```vim
Plug 'hyogoa2c/md-headings'

" In your init.vim or after/plugin/md-headings.lua
lua << EOF
require("md-headings").setup()
EOF
```

### Manual Installation

```bash
git clone https://github.com/hyogoa2c/md-headings.git \
  ~/.local/share/nvim/site/pack/plugins/start/md-headings
```

## Usage

### Commands

**Numbering:**
- `:MarkdownNumberHeadings` - Number all headings in the current buffer
- `:MarkdownRemoveNumbers` - Remove all numbers from headings
- `:MarkdownToggleNumbers` - Toggle the plugin on/off

**Table of Contents:**
- `:MarkdownTOC` - Create table of contents at cursor (plain, no numbers)
- `:MarkdownTOCNumbered` - Create table of contents with hierarchical numbers

### Quick Start

1. Open a markdown file
2. Run `:MarkdownNumberHeadings`
3. All headings will be numbered hierarchically

### Example: Heading Numbering

**Before:**
```markdown
# Introduction
## Background
### Some Detail
# Main Content
## Section A
## Section B
### Subsection B.1
```

**After running `:MarkdownNumberHeadings`:**
```markdown
# 1. Introduction
## 1.1. Background
### 1.1.1. Some Detail
# 2. Main Content
## 2.1. Section A
## 2.2. Section B
### 2.2.1. Subsection B.1
```

### Example: Table of Contents

Place your cursor where you want the TOC and run `:MarkdownTOC`:

```markdown
## Table of Contents

- [Introduction](#introduction)
  - [Background](#background)
    - [Some Detail](#some-detail)
- [Main Content](#main-content)
  - [Section A](#section-a)
  - [Section B](#section-b)
    - [Subsection B.1](#subsection-b-1)
```

Or use `:MarkdownTOCNumbered` to include numbers:

```markdown
## Table of Contents

- [1. Introduction](#introduction)
  - [1.1. Background](#background)
    - [1.1.1. Some Detail](#some-detail)
- [2. Main Content](#main-content)
  - [2.1. Section A](#section-a)
  - [2.2. Section B](#section-b)
    - [2.2.1. Subsection B.1](#subsection-b-1)
```

## Configuration

The plugin works with sensible defaults out of the box. To customize:

```lua
require("md-headings").setup({
  -- Enable/disable the plugin
  enabled = true,

  -- Number separator: "." or ")"
  separator = ".",

  -- Add space between number and heading text
  add_space = true,

  -- Start numbering from this level (1-6)
  -- Set to 2 to skip H1 headings
  start_level = 1,

  -- Auto-number on save (disabled by default)
  auto_number_on_save = false,

  -- Skip headings matching these patterns
  skip_patterns = {},  -- e.g., {"^TOC", "^Table of Contents"}

  -- Table of Contents settings
  toc_add_header = true,      -- Add "Table of Contents" header
  toc_indent_size = 2,        -- Spaces per indentation level
})
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enabled` | boolean | `true` | Enable/disable the plugin |
| `separator` | string | `"."` | Number separator ("." or ")") |
| `add_space` | boolean | `true` | Add space between number and text |
| `start_level` | number | `1` | Start numbering from this heading level (1-6) |
| `auto_number_on_save` | boolean | `false` | Automatically renumber on save |
| `skip_patterns` | table | `{}` | Lua patterns to skip headings |
| `toc_add_header` | boolean | `true` | Add "Table of Contents" header to TOC |
| `toc_indent_size` | number | `2` | Spaces per indentation level in TOC |

### Example Configurations

#### Use parentheses instead of periods

```lua
require("md-headings").setup({
  separator = ")",
})
```

Output: `# 1) Heading`, `## 1.1) Subheading`

#### Skip H1 headings

```lua
require("md-headings").setup({
  start_level = 2,
})
```

Only numbers H2-H6 headings.

#### Auto-number on save

```lua
require("md-headings").setup({
  auto_number_on_save = true,
})
```

Automatically renumbers headings whenever you save the file.

## How It Works

1. **Parsing**: The plugin scans the buffer line by line, detecting ATX-style headings (`#`, `##`, `###`, etc.)
2. **Code Block Detection**: Lines inside fenced code blocks (` ``` `) are ignored to avoid false positives
3. **Number Stripping**: Existing numbers are removed from headings before renumbering
4. **Hierarchical Numbering**: A counter array tracks each heading level, resetting deeper levels when moving up
5. **Buffer Update**: Modified heading lines are written back to the buffer

## Edge Cases Handled

- Code blocks with `#` symbols are not numbered
- Existing numbers in various formats are removed (1., 1.1., 1), 1.1), etc.)
- Skipped heading levels are handled gracefully
- Inline code within headings is preserved
- Empty headings are skipped

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - see LICENSE file for details

## Acknowledgments

Built with modern Neovim's Lua API for optimal performance and maintainability.
