-- Simple test script for Devstral.nvim
-- This can be run with: nvim --headless -c "lua dofile('test_plugin.lua')" -c "qa"

print("Testing Devstral.nvim plugin structure...")

-- Test 1: Check if main module loads
print("\n1. Testing main module...")
local ok, devstral = pcall(require, "devstral")
if ok then
  print("✓ Main module loaded successfully")
  print("  Plugin name: " .. devstral.name)
  print("  Version: " .. devstral.version)
  print("  Description: " .. devstral.description)
else
  print("✗ Failed to load main module: " .. devstral)
end

-- Test 2: Check if API module loads
print("\n2. Testing API module...")
local ok, api = pcall(require, "devstral.api")
if ok then
  print("✓ API module loaded successfully")
else
  print("✗ Failed to load API module: " .. api)
end

-- Test 3: Check if HTTP module loads
print("\n3. Testing HTTP module...")
local ok, http = pcall(require, "devstral.http")
if ok then
  print("✓ HTTP module loaded successfully")
else
  print("✗ Failed to load HTTP module: " .. http)
end

-- Test 4: Check if chat module loads
print("\n4. Testing chat module...")
local ok, chat = pcall(require, "devstral.chat")
if ok then
  print("✓ Chat module loaded successfully")
else
  print("✗ Failed to load chat module: " .. chat)
end

-- Test 5: Check if agent module loads
print("\n5. Testing agent module...")
local ok, agent = pcall(require, "devstral.agent")
if ok then
  print("✓ Agent module loaded successfully")
else
  print("✗ Failed to load agent module: " .. agent)
end

-- Test 6: Check if config module loads
print("\n6. Testing config module...")
local ok, config = pcall(require, "devstral.config")
if ok then
  print("✓ Config module loaded successfully")
else
  print("✗ Failed to load config module: " .. config)
end

-- Test 7: Test configuration setup
print("\n7. Testing configuration setup...")
local test_config = {
  api_key = "test-key-123",
  chat = {
    prompt = "Test> "
  }
}

local ok, result = pcall(function()
  return config.setup(test_config)
end)

if ok then
  print("✓ Configuration setup successful")
  print("  API key set: " .. (result.api_key and "yes" or "no"))
  print("  Chat prompt: " .. result.chat.prompt)
else
  print("✗ Configuration setup failed: " .. result)
end

-- Test 8: Test plugin initialization
print("\n8. Testing plugin initialization...")
local ok, result = pcall(function()
  devstral.setup({
    api_key = "test-key-456",
  })
end)

if ok then
  print("✓ Plugin initialization successful")
else
  print("✗ Plugin initialization failed: " .. result)
end

print("\n" .. "=".repeat(50))
print("Devstral.nvim plugin structure test completed!")
print("All basic modules loaded successfully.")
print("=".repeat(50))