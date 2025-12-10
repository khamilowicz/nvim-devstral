-- Devstral API Client
-- Handles communication with Devstral API

local M = {}
local config = require("devstral").config
local http = require("devstral.http")

-- API endpoints
local API_ENDPOINTS = {
  chat = "/chat/completions",
  agent = "/agent/analyze",
  suggestions = "/agent/suggestions",
  tools = "/tools/execute",
}

function M.setup()
  -- Initialize HTTP client
  http.setup({
    base_url = config.api_url,
    headers = {
      Authorization = "Bearer " .. (config.api_key or ""),
      ["Content-Type"] = "application/json",
    },
  })
end

--- Send a chat message to Devstral API
-- @param messages table List of messages in format {role = "user"|"assistant", content = "message"}
-- @param options table Additional options (model, temperature, etc.)
-- @return table Response from API or nil if error
-- @return string Error message if any
function M.chat_completion(messages, options)
  if not config.api_key then
    return nil, "Devstral API key not configured"
  end
  
  local payload = {
    messages = messages,
    model = options.model or "devstral-2",
    temperature = options.temperature or 0.7,
    max_tokens = options.max_tokens or 1000,
    stream = options.stream or false,
  }
  
  local response, err = http.post(API_ENDPOINTS.chat, payload)
  if err then
    return nil, "Failed to send chat request: " .. err
  end
  
  return response, nil
end

--- Send code analysis request to Devstral Agent
-- @param code string Code to analyze
-- @param language string Programming language
-- @param context table Additional context
-- @return table Response from API or nil if error
-- @return string Error message if any
function M.analyze_code(code, language, context)
  if not config.api_key then
    return nil, "Devstral API key not configured"
  end
  
  local payload = {
    code = code,
    language = language,
    context = context or {},
    model = "devstral-agent",
  }
  
  local response, err = http.post(API_ENDPOINTS.agent, payload)
  if err then
    return nil, "Failed to analyze code: " .. err
  end
  
  return response, nil
end

--- Get suggestions from Devstral Agent
-- @param code string Code to get suggestions for
-- @param language string Programming language
-- @return table Response from API or nil if error
-- @return string Error message if any
function M.get_suggestions(code, language)
  if not config.api_key then
    return nil, "Devstral API key not configured"
  end
  
  local payload = {
    code = code,
    language = language,
    model = "devstral-agent",
  }
  
  local response, err = http.post(API_ENDPOINTS.suggestions, payload)
  if err then
    return nil, "Failed to get suggestions: " .. err
  end
  
  return response, nil
end

--- Execute tool via Devstral API
-- @param tool string Tool name
-- @param params table Tool parameters
-- @return table Response from API or nil if error
-- @return string Error message if any
function M.execute_tool(tool, params)
  if not config.api_key then
    return nil, "Devstral API key not configured"
  end
  
  local payload = {
    tool = tool,
    params = params or {},
  }
  
  local response, err = http.post(API_ENDPOINTS.tools, payload)
  if err then
    return nil, "Failed to execute tool: " .. err
  end
  
  return response, nil
end

return M