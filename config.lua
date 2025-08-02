local M = {}

local defaults = {
  model = "qwen3-coder:30b",
  system_prompt = "You are an senior software engineer, autocomplete the line with just one line of code, dont explain or dont generate text, just one line of code without markdown, dont put ```, put direcly the code, please.",
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
