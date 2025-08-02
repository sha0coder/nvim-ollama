

local M = {}

local config = require("nvim-ollama.config")

local function send_to_ollama(prompt)
  local http = require("http")
  local json = require("json")

  local model = config.get_model()
  local system_prompt = config.get_system_prompt()
  local full_prompt = string.format("%s\n\n%s", system_prompt, prompt)

  local body = json.encode({
    model = model,
    prompt = full_prompt,
    stream = false
  })

  local res = http.post("http://localhost:11434/api/generate", {
    headers = {
      ["Content-Type"] = "application/json"
    },
    body = body
  })

  if res.status == 200 then
    local data = json.decode(res.body)
    return data.response
  else
    vim.notify("Error in Ollama: " .. res.status, vim.log.levels.ERROR)
    return nil
  end
end

local function complete_current_line()
  local line = vim.api.nvim_get_current_line()
  local pos = vim.api.nvim_win_get_cursor(0)[2]

  local context = {
    line = line,
    position = pos,
    buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  }

  local prompt = string.format(
    "Complete the code in the following line: %s\nContextt:\n%s",
    line,
    table.concat(context.buffer, "\n")
  )

  local response = send_to_ollama(prompt)
  if response then
    -- Insert response on current line
    local current_line = vim.api.nvim_get_current_line()
    local new_line = string.sub(response, 1, 100) -- Limit length
    vim.api.nvim_set_current_line(current_line .. new_line)
  end
end

-- Config autocmd for real time self completing
local function setup_autocomplete()
  vim.api.nvim_create_autocmd("TextChangedI", {
    callback = function()
      -- Config frequency here
      complete_current_line()
    end,
    pattern = "*.lua,*.py,*.js,*.go,*.rs"
  })
end

M.setup = function(opts)
  config.setup(opts)
  setup_autocomplete()
end

return M
