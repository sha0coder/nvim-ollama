local M = {}

local config = require("ollama.config")
local json = vim.json or require("dkjson")
local timer = vim.loop.new_timer()


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
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))  -- current line (1-based)
  local start_line = math.max(0, row - 1 - 15)  -- max 15 previous lines
  local end_line = row - 1  -- zero-based index of current line

  local lines_before = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  local current_line = vim.api.nvim_buf_get_lines(0, end_line, end_line + 1, false)[1] or ""

  local prompt = string.format(
    "Complete the code in the following line: %s\nContext:\n%s",
    current_line,
    table.concat(lines_before, "\n")
  )

  local response = send_to_ollama(prompt)
  if response then
    -- Insert response on current line
    local clean_line = response:match("[^\n\r]+") or response
    local cur_line = vim.api.nvim_get_current_line()
    vim.api.nvim_set_current_line(cur_line .. clean_line)
  end
end


-- Config autocmd for real time self completing
local function setup_autocomplete()
    vim.api.nvim_create_autocmd("TextChangedI", {
        pattern = {"*.lua", "*.py", "*.rs", "*.js"},
        callback = function()
            timer:stop()
            timer:start(config.get_delay() or 400, 0, vim.schedule_wrap(complete_current_line))
         end,
    })
end

local function setup_manual_trigger()
    local key = config.get_keybind() or "<C-x>"
    vim.keymap.set("i", key, function()
        complete_current_line()
    end, { desc = "AI Complete line with Ollama", noremap = true, silent = true })
end

M.setup = function(opts)
    config.setup(opts)

    if config.get_trigger() == "manual" then
        setup_keybind(config.get_keybind())
    else
        setup_autocomplete()
    end

    vim.notify("nvim-ollama installed successfully", vim.log.levels.INFO)
end

return M

