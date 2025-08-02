local M = {}

local defaults = {
  model = "qwen3-coder:30b",
  system_prompt = [[
You are a strict code autocompletion engine. Your only task is to complete programming code.
Return exactly one valid line of code. Do not explain anything.
Do not wrap code in quotes or markdown.
Return only code. No comments, no explanations, no formatting, no extra words.
]],
  host = "localhost",
  port = 11434,
  trigger = "manual", -- "manual" or "auto"
  delay = 500,
  keybind = "<leader>i",
}


local user_config = {}

function M.setup(opts)
  user_config = vim.tbl_deep_extend("force", defaults, opts or {})
end

function M.get_model()
  return user_config.model
end

function M.get_system_prompt()
  return user_config.system_prompt
end

function M.get_delay()
  return user_config.delay
end

function M.get_port()
    return user_config.port
end

function M.get_host()
    return user_config.host
end

function M.get_trigger()
    return user_config.trigger
end

function M.get_keybind()
    return user_config.keybind
end



return M
