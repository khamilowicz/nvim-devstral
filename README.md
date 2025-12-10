# Devstral.nvim

A Neovim plugin for LazyVim that provides chat and agent assistant functionality with Devstral AI integration.

## Features

- **Chat Interface**: Interactive chat with Devstral AI models
- **Agent Assistant**: Code analysis and suggestions for your current buffer
- **LazyVim Integration**: Seamless integration with LazyVim ecosystem
- **Customizable**: Configure API keys, window sizes, and behavior

## Installation

### Using LazyVim

Add to your LazyVim configuration:

```lua
{
  "your-username/devstral.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",  -- Optional, for better HTTP handling
  },
  config = function()
    require("devstral").setup({
      api_key = "your-devstral-api-key",  -- Required for full functionality
      -- Other configuration options
    })
  end,
}
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/devstral.nvim.git ~/.local/share/nvim/site/pack/plugins/start/devstral.nvim
```

2. Add configuration to your `init.lua`:
```lua
require("devstral").setup({
  api_key = "your-devstral-api-key",
})
```

## Configuration

### Basic Configuration

```lua
require("devstral").setup({
  api_key = "your-api-key",  -- Required
  api_url = "https://api.devstral.ai/v1",  -- Default
  
  chat = {
    window = {
      width = 0.8,    -- 80% of editor width
      height = 0.7,   -- 70% of editor height
      border = "rounded",
    },
    prompt = "Devstral> ",
  },
  
  agent = {
    enabled = true,
    auto_suggest = false,
    max_file_size = 100000,  -- 100KB
  },
})
```

### LazyVim Specific Configuration

```lua
require("devstral.config").setup({
  lazyvim = {
    integrate_ui = true,
    keymaps = {
      chat = "<leader>dc",
      chat_toggle = "<leader>dt",
      agent = "<leader>da",
      suggestions = "<leader>ds",
    },
  },
})
```

## Usage

### Chat Commands

- `:DevstralChat` - Open the chat interface
- `:DevstralChatToggle` - Toggle the chat interface

### Agent Commands

- `:DevstralAgent` - Run code analysis on current buffer
- `:DevstralAgentSuggest` - Get suggestions for current buffer

### Keymaps (Default)

- `<leader>dc` - Open Devstral Chat
- `<leader>dt` - Toggle Devstral Chat
- `<leader>da` - Run Devstral Agent
- `<leader>ds` - Get Devstral Suggestions

## API Configuration

You need a Devstral API key for full functionality. You can get one by signing up at [Devstral AI](https://devstral.ai).

## Requirements

- Neovim 0.7+ (for Lua API)
- curl (for HTTP requests, fallback if plenary.nvim not available)
- Devstral API key (for full functionality)

## Development

### Structure

```
nvim-devstral/
├── lua/
│   └── devstral/
│       ├── init.lua          # Main plugin
│       ├── api.lua           # API client
│       ├── http.lua          # HTTP client
│       ├── chat.lua          # Chat interface
│       ├── agent.lua         # Agent functionality
│       ├── config.lua        # Configuration
│       └── plugin.lua        # LazyVim plugin spec
└── doc/
    └── devstral.txt        # Vim help file
```

### Building Documentation

Generate help tags:
```bash
:helptags ALL
```

## License

MIT License. See `LICENSE` for details.

## Contributing

Contributions are welcome! Please open issues or pull requests on GitHub.

## Support

For support, please open an issue on the GitHub repository or contact support@devstral.ai.