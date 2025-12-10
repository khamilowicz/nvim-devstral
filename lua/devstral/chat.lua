-- Devstral Chat Interface
-- Provides chat functionality with Devstral AI

local M = {}
local api = require("devstral.api")
local config = require("devstral").config

-- Chat state
local chat_state = {
  messages = {},
  is_open = false,
  bufnr = nil,
  winid = nil,
}

function M.setup()
  -- Initialize chat state
  chat_state.messages = {
    {
      role = "assistant",
      content = "Welcome to Devstral.nvim! How can I assist you today?",
    }
  }
end

--- Open chat interface
function M.open_chat()
  if chat_state.is_open then
    return
  end
  
  -- Create buffer
  chat_state.bufnr = vim.api.nvim_create_buf(false, true)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(chat_state.bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(chat_state.bufnr, "filetype", "devstral-chat")
  vim.api.nvim_buf_set_option(chat_state.bufnr, "buftype", "nofile")
  
  -- Set up buffer content
  M._update_buffer()
  
  -- Create window
  local width = math.floor(vim.o.columns * config.chat.window.width)
  local height = math.floor(vim.o.lines * config.chat.window.height)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = config.chat.window.border,
  }
  
  chat_state.winid = vim.api.nvim_open_win(chat_state.bufnr, true, win_opts)
  
  -- Set up input prompt
  M._setup_input()
  
  -- Set up autocommands
  M._setup_autocommands()
  
  chat_state.is_open = true
  
  -- Focus the input
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("G", true, false, true), "n", true)
end

--- Toggle chat interface
function M.toggle_chat()
  if chat_state.is_open then
    M.close_chat()
  else
    M.open_chat()
  end
end

--- Close chat interface
function M.close_chat()
  if not chat_state.is_open then
    return
  end
  
  -- Clean up autocommands
  M._cleanup_autocommands()
  
  -- Close window
  if chat_state.winid and vim.api.nvim_win_is_valid(chat_state.winid) then
    vim.api.nvim_win_close(chat_state.winid, true)
  end
  
  -- Wipe buffer
  if chat_state.bufnr and vim.api.nvim_buf_is_valid(chat_state.bufnr) then
    vim.api.nvim_buf_delete(chat_state.bufnr, { force = true })
  end
  
  chat_state = {
    messages = chat_state.messages,  -- Preserve chat history
    is_open = false,
    bufnr = nil,
    winid = nil,
  }
end

--- Update buffer content with current chat messages
function M._update_buffer()
  if not chat_state.bufnr or not vim.api.nvim_buf_is_valid(chat_state.bufnr) then
    return
  end
  
  local lines = {}
  
  -- Add chat messages
  for _, message in ipairs(chat_state.messages) do
    local role_prefix = message.role == "user" and "You: " or "Devstral: "
    
    -- Split message content into lines
    local content_lines = vim.split(message.content, "\n")
    
    for i, line in ipairs(content_lines) do
      if i == 1 then
        table.insert(lines, role_prefix .. line)
      else
        table.insert(lines, string.rep(" ", #role_prefix) .. line)
      end
    end
    
    table.insert(lines, "")  -- Add empty line between messages
  end
  
  -- Add prompt
  table.insert(lines, config.chat.prompt)
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(chat_state.bufnr, 0, -1, false, lines)
  
  -- Set syntax highlighting
  M._apply_syntax_highlighting()
end

--- Apply syntax highlighting to chat messages
function M._apply_syntax_highlighting()
  if not chat_state.bufnr or not vim.api.nvim_buf_is_valid(chat_state.bufnr) then
    return
  end
  
  local ns = vim.api.nvim_create_namespace("DevstralChat")
  
  local line_count = 0
  for _, message in ipairs(chat_state.messages) do
    local role_prefix = message.role == "user" and "You: " or "Devstral: "
    local content_lines = vim.split(message.content, "\n")
    
    -- Highlight role prefix
    for i, line in ipairs(content_lines) do
      local start_col = 0
      local end_col = #role_prefix - 1
      
      if i == 1 then
        vim.api.nvim_buf_add_highlight(chat_state.bufnr, ns, "Devstral" .. message.role:sub(1,1):upper() .. message.role:sub(2), line_count, start_col, end_col)
      end
      
      line_count = line_count + 1
    end
    
    line_count = line_count + 1  -- Empty line
  end
end

--- Set up input prompt
function M._setup_input()
  -- Set up command-line input
  vim.api.nvim_buf_set_keymap(chat_state.bufnr, "n", "i", "", {
    callback = function()
      vim.ui.input({
        prompt = config.chat.prompt,
      }, function(input)
        if input and input ~= "" then
          M.send_message(input)
        end
      end)
    end,
    desc = "Start typing message",
  })
  
  -- Set up normal mode mapping to send message
  vim.api.nvim_buf_set_keymap(chat_state.bufnr, "n", "<CR>", "", {
    callback = function()
      vim.ui.input({
        prompt = config.chat.prompt,
      }, function(input)
        if input and input ~= "" then
          M.send_message(input)
        end
      end)
    end,
    desc = "Send message",
  })
end

--- Send message to Devstral API
-- @param message string User message
function M.send_message(message)
  if not message or message == "" then
    return
  end
  
  -- Add user message to chat
  table.insert(chat_state.messages, {
    role = "user",
    content = message,
  })
  
  -- Update buffer
  M._update_buffer()
  
  -- Show typing indicator
  table.insert(chat_state.messages, {
    role = "assistant",
    content = "Thinking...",
  })
  M._update_buffer()
  
  -- Send to API
  local response, err = api.chat_completion(chat_state.messages, {
    model = "devstral-2",
    temperature = 0.7,
  })
  
  -- Remove typing indicator
  table.remove(chat_state.messages)
  
  if err then
    table.insert(chat_state.messages, {
      role = "assistant",
      content = "Error: " .. err,
    })
    M._update_buffer()
    return
  end
  
  -- Add assistant response
  if response and response.choices and response.choices[1] and response.choices[1].message then
    table.insert(chat_state.messages, response.choices[1].message)
  else
    table.insert(chat_state.messages, {
      role = "assistant",
      content = "Sorry, I didn't understand that.",
    })
  end
  
  -- Update buffer
  M._update_buffer()
end

--- Set up autocommands for chat buffer
function M._setup_autocommands()
  local group = vim.api.nvim_create_augroup("DevstralChat", { clear = true })
  
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    buffer = chat_state.bufnr,
    callback = function()
      M.close_chat()
    end,
  })
  
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = tostring(chat_state.winid),
    callback = function()
      M.close_chat()
    end,
  })
end

--- Clean up autocommands
function M._cleanup_autocommands()
  pcall(vim.api.nvim_del_augroup_by_name, "DevstralChat")
end

return M