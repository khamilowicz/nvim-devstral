-- Devstral.nvim Configuration
-- Handles plugin configuration and LazyVim integration

local M = {}

-- Default configuration
M.defaults = {
  api_key = nil,  -- User must provide their Devstral API key
  api_url = "https://api.devstral.ai/v1",
  
  chat = {
    window = {
      width = 0.8,
      height = 0.7,
      border = "rounded",
    },
    prompt = "Devstral> ",
    -- Syntax highlighting groups
    highlight = {
      user = "DevstralUser",
      assistant = "DevstralAssistant",
    },
  },
  
  agent = {
    enabled = true,
    auto_suggest = false,
    -- Filetypes to enable agent for (nil for all)
    filetypes = nil,
    -- Maximum file size for analysis (in bytes)
    max_file_size = 100000,  -- 100KB
  },
  
  -- LazyVim specific options
  lazyvim = {
    -- Whether to integrate with LazyVim UI
    integrate_ui = true,
    -- Keymaps (can be overridden)
    keymaps = {
      chat = "<leader>dc",
      chat_toggle = "<leader>dt",
      agent = "<leader>da",
      suggestions = "<leader>ds",
    },
  },
}

-- Current configuration
M.config = {}

--- Setup configuration
-- @param user_config table User provided configuration
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", {}, M.defaults, user_config or {})
  
  -- Validate configuration
  M._validate_config()
  
  -- Apply syntax highlighting
  M._setup_highlighting()
  
  return M.config
end

--- Validate configuration
function M._validate_config()
  -- Check API key
  if not M.config.api_key then
    vim.notify("Devstral.nvim: api_key not configured. Some features will be disabled.", vim.log.levels.WARN)
  end
  
  -- Validate window dimensions
  if M.config.chat.window.width <= 0 or M.config.chat.window.width > 1 then
    vim.notify("Devstral.nvim: chat.window.width should be between 0 and 1", vim.log.levels.WARN)
    M.config.chat.window.width = math.max(0.1, math.min(1.0, M.config.chat.window.width))
  end
  
  if M.config.chat.window.height <= 0 or M.config.chat.window.height > 1 then
    vim.notify("Devstral.nvim: chat.window.height should be between 0 and 1", vim.log.levels.WARN)
    M.config.chat.window.height = math.max(0.1, math.min(1.0, M.config.chat.window.height))
  end
end

--- Setup syntax highlighting
function M._setup_highlighting()
  -- User messages
  vim.api.nvim_set_hl(0, M.config.chat.highlight.user, {
    fg = "#7AA2F7",  -- Blue
    bold = true,
  })
  
  -- Assistant messages
  vim.api.nvim_set_hl(0, M.config.chat.highlight.assistant, {
    fg = "#BB9AF7",  -- Purple
    bold = true,
  })
end

--- Get configuration for LazyVim integration
-- @return table Configuration suitable for LazyVim
function M.get_lazyvim_config()
  return {
    -- Main plugin configuration
    config = function(_, opts)
      require("devstral").setup(opts)
    end,
    
    -- Plugin dependencies
    dependencies = {
      -- Required for HTTP requests
      {
        "nvim-lua/plenary.nvim",
        optional = true,  -- We have fallback with curl
      },
    },
    
    -- LazyVim specific options
    opts = {
      api_key = M.config.api_key,
      api_url = M.config.api_url,
      chat = M.config.chat,
      agent = M.config.agent,
    },
    
    -- Keymaps for LazyVim
    keys = {
      {
        M.config.lazyvim.keymaps.chat,
        "<cmd>DevstralChat<CR>",
        desc = "Open Devstral Chat",
      },
      {
        M.config.lazyvim.keymaps.chat_toggle,
        "<cmd>DevstralChatToggle<CR>",
        desc = "Toggle Devstral Chat",
      },
      {
        M.config.lazyvim.keymaps.agent,
        "<cmd>DevstralAgent<CR>",
        desc = "Run Devstral Agent",
      },
      {
        M.config.lazyvim.keymaps.suggestions,
        "<cmd>DevstralAgentSuggest<CR>",
        desc = "Get Devstral Suggestions",
      },
    },
    
    -- Commands
    cmd = {
      "DevstralChat",
      "DevstralChatToggle",
      "DevstralAgent",
      "DevstralAgentSuggest",
    },
  }
end

return M