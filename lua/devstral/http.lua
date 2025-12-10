-- HTTP Client for Devstral.nvim
-- Handles HTTP requests with retry logic and error handling

local M = {}
local config = {}

-- Default HTTP client configuration
local defaults = {
  base_url = "",
  timeout = 30000,  -- 30 seconds
  max_retries = 3,
  retry_delay = 1000,  -- 1 second
  headers = {
    ["Content-Type"] = "application/json",
    ["User-Agent"] = "devstral.nvim/0.1.0",
  },
}

function M.setup(user_config)
  config = vim.tbl_deep_extend("force", {}, defaults, user_config or {})
end

--- Make HTTP request
-- @param method string HTTP method (GET, POST, etc.)
-- @param path string API endpoint path
-- @param body table|nil Request body
-- @param headers table|nil Additional headers
-- @return table Response body
-- @return string Error message if any
local function request(method, path, body, headers)
  local url = config.base_url .. path
  
  -- Merge headers
  local final_headers = vim.tbl_deep_extend("force", {}, config.headers, headers or {})
  
  -- Convert body to JSON if it's a table
  local body_str = nil
  if body then
    local ok, json_body = pcall(vim.json.encode, body)
    if not ok then
      return nil, "Failed to encode request body: " .. json_body
    end
    body_str = json_body
  end
  
  -- Use curl for HTTP requests (more reliable than LuaSocket)
  local cmd = {"curl", "-s", "-X", method, "-H", "Content-Type: application/json"}
  
  -- Add headers
  for key, value in pairs(final_headers) do
    table.insert(cmd, "-H")
    table.insert(cmd, key .. ": " .. value)
  end
  
  -- Add body if present
  if body_str then
    table.insert(cmd, "-d")
    table.insert(cmd, body_str)
  end
  
  -- Add URL
  table.insert(cmd, url)
  
  -- Execute command
  local handle = io.popen(table.concat(cmd, " "))
  if not handle then
    return nil, "Failed to execute curl command"
  end
  
  local response = handle:read("*a")
  handle:close()
  
  -- Parse JSON response
  local ok, parsed = pcall(vim.json.decode, response)
  if not ok then
    return nil, "Failed to parse response: " .. parsed
  end
  
  return parsed, nil
end

--- Make HTTP request with retry logic
-- @param method string HTTP method
-- @param path string API endpoint path
-- @param body table|nil Request body
-- @param headers table|nil Additional headers
-- @return table Response body
-- @return string Error message if any
function M.request_with_retry(method, path, body, headers)
  local retries = 0
  local last_error = nil
  
  while retries < config.max_retries do
    local response, err = request(method, path, body, headers)
    
    if response then
      return response, nil
    end
    
    last_error = err
    retries = retries + 1
    
    if retries < config.max_retries then
      vim.loop.sleep(config.retry_delay)
    end
  end
  
  return nil, "Request failed after " .. config.max_retries .. " retries: " .. last_error
end

--- GET request
-- @param path string API endpoint path
-- @param headers table|nil Additional headers
-- @return table Response body
-- @return string Error message if any
function M.get(path, headers)
  return M.request_with_retry("GET", path, nil, headers)
end

--- POST request
-- @param path string API endpoint path
-- @param body table Request body
-- @param headers table|nil Additional headers
-- @return table Response body
-- @return string Error message if any
function M.post(path, body, headers)
  return M.request_with_retry("POST", path, body, headers)
end

--- PUT request
-- @param path string API endpoint path
-- @param body table Request body
-- @param headers table|nil Additional headers
-- @return table Response body
-- @return string Error message if any
function M.put(path, body, headers)
  return M.request_with_retry("PUT", path, body, headers)
end

--- DELETE request
-- @param path string API endpoint path
-- @param headers table|nil Additional headers
-- @return table Response body
-- @return string Error message if any
function M.delete(path, headers)
  return M.request_with_retry("DELETE", path, nil, headers)
end

return M