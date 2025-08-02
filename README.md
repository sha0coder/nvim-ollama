
Lazy plugin for NeoVim to autocomplete using an ollama offline model.



```lua
{
  "sha0coder/nvim-ollama.nvim",
  config = function()
    require("ollama_autocomplete").setup({
      model = "qwen3-coder:30b",
    })
  end
}
```



```lua
{
  "sha0coder/nvim-ollama.nvim",
  config = function()
    require("nvim-ollama").setup({
      model = "qwen3-coder:30b", 
      system_prompt = "custom prompt.",
    })
  end
}
```
