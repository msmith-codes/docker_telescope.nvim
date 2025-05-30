# docker_telescope.nvim

## What is Docker Telescope?

`docker_telescope.nvim` is a `telescope.nvim` plugin that brings the ability to view your Docker images using telescope!

![screenshot](https://github.com/user-attachments/assets/6f7af552-dd8e-4adb-b4c2-e358bef54eb7)

## Docker Telescope Table of Contents
- [Getting Started](#getting-started)
- [Contributing](#contributing)

## Getting Started
This section should assist you with installing and using Docker Telescope.

### Required dependencies
[nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) is required.

### Installation and Customization
Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
-- plugins/docker_telescope.lua
return {
  'msmith-codes/docker_telescope.nvim', tag = 'v0.1.0',
  dependencies = { 'nvim-telescope/telescope.nvim' }
  config = function()
    require("docker_telescope").setup({
      key = "<leader>di"
    })
  end,
}
```

## Contributing
All contributions are welcome! Just fork and open a pull request!
