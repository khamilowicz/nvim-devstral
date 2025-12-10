-- Example configuration for Devstral.nvim
-- Place this in your Neovim config or use it as a reference

local devstral = require("devstral")

devstral.setup({
  -- REQUIRED: Your Devstral API key
  -- Get it from https://devstral.ai
  api_key = "your-api-key-here",
  
  -- Optional: Custom API URL (default: "https://api.devstral.ai/v1")
  api_url = "https://api.devstral.ai/v1",
  
  -- Chat configuration
  chat = {
    window = {
      width = 0.8,          -- 80% of editor width
      height = 0.7,         -- 70% of editor height
      border = "rounded",  -- Window border style
    },
    prompt = "Devstral> ",  -- Chat prompt
    highlight = {
      user = "DevstralUser",      -- Highlight group for user messages
      assistant = "DevstralAssistant",  -- Highlight group for assistant messages
    },
  },
  
  -- Agent configuration
  agent = {
    enabled = true,               -- Enable agent functionality
    auto_suggest = false,         -- Don't show suggestions automatically
    filetypes = nil,              -- nil means all filetypes (or specify {"lua", "python", "javascript"})
    max_file_size = 100000,       -- 100KB maximum file size for analysis
  },
  
  -- LazyVim specific configuration (optional)
  lazyvim = {
    integrate_ui = true,         -- Integrate with LazyVim UI
    keymaps = {
      chat = "<leader>dc",        -- Open chat
      chat_toggle = "<leader>dt", -- Toggle chat
      agent = "<leader>da",       -- Run agent analysis
      suggestions = "<leader>ds", -- Get suggestions
    },
  },
})

-- Custom syntax highlighting (optional)
vim.api.nvim_set_hl(0, "DevstralUser", {
  fg = "#7AA2F7",  -- Blue
  bold = true,
})

vim.api.nvim_set_hl(0, "DevstralAssistant", {
  fg = "#BB9AF7",  -- Purple
  bold = true,
})

-- Custom keymaps (optional - these are set by default)
-- vim.keymap.set("n", "<leader>dc", "<cmd>DevstralChat<CR>", { desc = "Open Devstral Chat" })
-- vim.keymap.set("n", "<leader>dt", "<cmd>DevstralChatToggle<CR>", { desc = "Toggle Devstral Chat" })
-- vim.keymap.set("n", "<leader>da", "<cmd>DevstralAgent<CR>", { desc = "Run Devstral Agent" })
-- vim.keymap.set("n", "<leader>ds", "<cmd>DevstralAgentSuggest<CR>", { desc = "Get Devstral Suggestions" })