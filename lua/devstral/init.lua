-- Devstral.nvim - Chat and Agent Assistant for Neovim
-- Main plugin initialization

local M = {}

-- Plugin metadata
M.name = "devstral.nvim"
M.version = "0.1.0"
M.description = "Chat and Agent Assistant with Devstral integration for Neovim"
M.author = "Devstral Team"

-- Default configuration
M.defaults = {
  api_key = nil,  -- User should provide their Devstral API key
  api_url = "https://api.devstral.ai/v1",
  chat = {
    window = {
      width = 0.8,
      height = 0.7,
      border = "rounded",
    },
    prompt = "Devstral> ",
  },
  agent = {
    enabled = true,
    auto_suggest = false,
  },
}

-- Current configuration
M.config = {}

-- Setup function
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", {}, M.defaults, user_config or {})
  
  -- Validate configuration
  if not M.config.api_key then
    vim.notify("Devstral.nvim: api_key is required for full functionality", vim.log.levels.WARN)
  end
  
  -- Load modules
  require("devstral.chat").setup()
  require("devstral.agent").setup()
  require("devstral.api").setup()
  
  -- Set up commands
  M._setup_commands()
  
  -- Set up keymaps
  M._setup_keymaps()
  
  vim.notify("Devstral.nvim initialized!", vim.log.levels.INFO)
end

function M._setup_commands()
  -- Chat commands
  vim.api.nvim_create_user_command("DevstralChat", function()
    require("devstral.chat").open_chat()
  end, { desc = "Open Devstral chat interface" })
  
  vim.api.nvim_create_user_command("DevstralChatToggle", function()
    require("devstral.chat").toggle_chat()
  end, { desc = "Toggle Devstral chat interface" })
  
  -- Agent commands
  vim.api.nvim_create_user_command("DevstralAgent", function()
    require("devstral.agent").run_agent()
  end, { desc = "Run Devstral agent on current buffer" })
  
  vim.api.nvim_create_user_command("DevstralAgentSuggest", function()
    require("devstral.agent").get_suggestions()
  end, { desc = "Get suggestions from Devstral agent" })
end

function M._setup_keymaps()
  -- Set up default keymaps
  vim.keymap.set("n", "<leader>dc", "<cmd>DevstralChat<CR>", { desc = "Open Devstral Chat" })
  vim.keymap.set("n", "<leader>dt", "<cmd>DevstralChatToggle<CR>", { desc = "Toggle Devstral Chat" })
  vim.keymap.set("n", "<leader>da", "<cmd>DevstralAgent<CR>", { desc = "Run Devstral Agent" })
  vim.keymap.set("n", "<leader>ds", "<cmd>DevstralAgentSuggest<CR>", { desc = "Get Devstral Suggestions" })
end

return M