# nvim-ollama  NeoVim AI plugin


100% offline NeoVim AI completion using ollama. 

By default it's using `qwen3-coder:30b`
Use Lazy plugins to install it.

## Usage

by default is manual mode with the keybind F2.
In manual mode press F2 and wait a moment.
In auto mode (less convinient) is sending every delay time the query to ollama.


## Basic working configuration

```lua
{
  "sha0coder/nvim-ollama",
    opts = {
        model = "qwen3-coder:30b",
        trigger = "manual",
        keybind = "<F2>",
    }
}
```

## More customizable configuration

```lua
{
  "sha0coder/nvim-ollama",
    opts = {
        model = "qwen3-coder:30b",
        trigger = "auto",
        keybind = "<F2>",
        host = "1.2.3.4" -- default localhost
        port = "11111" -- default 11434
        delay = 900 -- default 400
        context = 20 -- default 15 this is the previous lines to the current line to send to ollama.


        system_prompt = [[
          something
]]

    }
}
```


## Default system prompt
```
You are a strict code autocompletion engine. Your only task is to complete programming code.
Return exactly one valid line of code. Do not explain anything.
Do not wrap code in quotes or markdown.
Return only code. No comments, no explanations, no formatting, no extra words.
``` 

Its important to use a good prompt for avoiding text or code in markdowns.
