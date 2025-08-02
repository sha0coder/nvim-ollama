

local M = {}

local config = require("nvim-ollama.config")

-- Conexión a Ollama API
local function send_to_ollama(prompt)
  local http = require("http")
  local json = require("json") -- Asegúrate de tener un módulo JSON

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
    vim.notify("Error en Ollama: " .. res.status, vim.log.levels.ERROR)
    return nil
  end
end

-- Autocompletar línea actual
local function complete_current_line()
  local line = vim.api.nvim_get_current_line()
  local pos = vim.api.nvim_win_get_cursor(0)[2]

  local context = {
    line = line,
    position = pos,
    buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  }

  local prompt = string.format(
    "Completa el código en la siguiente línea: %s\nContexto:\n%s",
    line,
    table.concat(context.buffer, "\n")
  )

  local response = send_to_ollama(prompt)
  if response then
    -- Insertar respuesta en la línea actual
    local current_line = vim.api.nvim_get_current_line()
    local new_line = string.sub(response, 1, 100) -- Limitar longitud
    vim.api.nvim_set_current_line(current_line .. new_line)
  end
end

-- Configurar autocmd para autocompletar en tiempo real
local function setup_autocomplete()
  vim.api.nvim_create_autocmd("TextChangedI", {
    callback = function()
      -- Puedes ajustar la frecuencia o condiciones aquí
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
