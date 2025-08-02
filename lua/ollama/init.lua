local M = {}

local config = require("ollama.config")
local json = vim.json or require("dkjson")
local timer = vim.loop.new_timer()
local debounce_ms = 400


local function log_to_file(msg)
  local f = io.open("/tmp/nvim-ollama.log", "a")
  if f then
    f:write(os.date() .. " - " .. msg .. "\n")
    f:close()
  end
end

local function send_to_ollama(prompt)
  local model = config.get_model()
  local system_prompt = config.get_system_prompt()

  local full_prompt = string.format("%s\n\n%s", system_prompt, prompt)

  local body = json.encode({
    model = model,
    prompt = full_prompt,
    stream = false,
  })

  log_to_file(body);

  local result = vim.system({
    "curl", "-s", "-X", "POST",
    "-H", "Content-Type: application/json",
    "-d", body,
    "http://localhost:11434/api/generate"
  }, { text = true }):wait()

  if result.code == 0 then
    local ok, data = pcall(json.decode, result.stdout)
    if ok and data and data.response then
      return data.response
    else
      vim.notify("Error decodificando JSON de Ollama", vim.log.levels.ERROR)
      return nil
    end
  else
    vim.notify("Error enviando a Ollama: " .. (result.stderr or ""), vim.log.levels.ERROR)
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
        pattern = {"*.lua", "*.py", "*.rs", "*.js"},
        callback = function()
            timer:stop()
            timer:start(debounce_ms, 0, vim.schedule_wrap(complete_current_line))
         end,
    })
--[[
  vim.api.nvim_create_autocmd("TextChangedI", {
    callback = function()
      local ft = vim.bo.filetype
          if ft == "lua" or ft == "python" or ft == "rust" or ft == "javascript" then
          timer:stop()
          timer:start(debounce_ms, 0, vim.schedule_wrap(function()
                complete_current_line()
          end))
      end
    end,
    pattern = "*",
  })
]]
end

M.setup = function(opts)

    config.setup(opts)
    vim.notify("Installing nvim-ollama ...", vim.log.levels.INFO)
    log_to_file("iniciando setup")
    log_to_file("setup ejecutado con modelo: " .. config.get_model() or "modelerr")
    log_to_file("setup ejecutado con modelo: " .. config.get_system_prompt() or "prompterr")

    vim.notify("options configured", vim.log.levels.INFO)
    setup_autocomplete()
    vim.notify("nvim-ollama installed successfully", vim.log.levels.INFO)
end

return M
