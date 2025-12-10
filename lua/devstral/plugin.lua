-- Devstral.nvim Plugin Specification for LazyVim
-- This file is loaded automatically by LazyVim

local config = require("devstral.config")

-- Setup default configuration
config.setup()

-- Load the main plugin
local devstral = require("devstral")

-- Initialize with default config (will be overridden by user config)
devstral.setup(config.config)

-- Set up LazyVim integration if available
if vim.g.lazyvim_loaded then
  local lazyvim_config = config.get_lazyvim_config()
  
  -- Apply LazyVim specific configurations
  if lazyvim_config.keys then
    for _, key in ipairs(lazyvim_config.keys) do
      vim.keymap.set(key[1]:sub(1,1), key[1]:sub(2), key[2], { desc = key.desc })
    end
  end
  
  vim.notify("Devstral.nvim: LazyVim integration enabled", vim.log.levels.INFO)
end

return devstral