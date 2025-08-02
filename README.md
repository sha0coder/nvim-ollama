
Lazy plugin for NeoVim to autocomplete using an ollama offline model.



```lua
{
  "sha0coder/nvim-ollama",
  config = function()
    require("ollama.config").setup({
      model = "qwen3-coder:30b",
    })
  end
}
```



```lua
{
  "sha0coder/nvim-ollama",
  config = function()
    require("ollama.config").setup({
      model = "qwen3-coder:30b", 
      system_prompt = "custom prompt.",
    })
  end
}
```
