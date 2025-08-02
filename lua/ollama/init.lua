

local M = {}

local config = require("ollama.config")

local function log_to_file(msg)
  local f = io.open("/tmp/nvim-ollama.log", "a")
  if f then
    f:write(os.date() .. " - " .. msg .. "\n")
    f:close()
  end
end

local function send_to_ollama(prompt)
  log_to_file("enviando prompt a ollama " .. prompt)

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
    log_to_file("respuesta de ollama: " .. data.response)
    return data.response
  else
    log_to_file("error enviando a ollama " .. res.status)
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
      local clean_line = response:match("[^\n\r]+") or response
      local current_line = vim.api.nvim_get_current_line()
      vim.api.nvim_set_current_line(current_line .. clean_line)
  end
end

-- Config autocmd for real time self completing
local function setup_autocomplete()
  vim.api.nvim_create_autocmd("TextChangedI", {
    callback = function()
      local ft = vim.bo.filetype
      if ft == "lua" or ft == "python" or ft == "rust" or ft == "javascript" then
        complete_current_line()
      end
    end,
    pattern = "*",
  })
end

M.setup = function(opts)

    config.setup(opts)
    vim.notify("Installing nvim-ollama ...", vim.log.levels.INFO)
    log_to_file("iniciando setup")
    log_to_file("setup ejecutado con modelo: " .. config.get_model())
    log_to_file("setup ejecutado con modelo: " .. config.get_system_prompt())

    vim.notify("options configured", vim.log.levels.INFO)
    setup_autocomplete()
    vim.notify("nvim-ollama installed successfully", vim.log.levels.INFO)
end

return M
