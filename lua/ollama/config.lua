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
  port = 11434
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

return M
