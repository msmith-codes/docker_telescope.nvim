local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local config = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

local function get_docker_images()
    local handle = io.popen("docker images --format '{{.Repository}}:{{.Tag}} {{.ID}} {{.Size}}'")
    if not handle then
        return {}
    end

    local result = {}
    for line in handle:lines() do
        local name, id, size = line:match("([^%s]+) ([^%s]+) ([^%s]+)")
        table.insert(result, {
            name = name,
            value = {
                id = id,
                size = size,
                raw = line,
            }
        })
    end

    handle:close()
    return result
end

function M.setup(opts)
    opts = opts or {}
    local key = opts.key or "<leader>di"
    vim.keymap.set("n", key, function()
        M.open(opts or {})
    end, { desc = "Open Docker Images Picker" })
end 

function M.open(opts)
    local docker_images = get_docker_images()
    pickers.new(opts, {
        finder = finders.new_table({
            results = docker_images,
            entry_maker = function(entry)
                return {
                    value = entry.value,
                    display = entry.name,
                    ordinal = entry.name,
                }
            end,
        }),
        attach_mappings = function(prompt_bufnr, map)
            map("i", "<CR>", function()
                local selection = action_state.get_selected_entry()
                if selection and selection.value then
                    vim.api.nvim_out_write("Selected Docker Image: " .. selection.value.id .. "\n")
                end
                actions.close(prompt_bufnr)
                vim.ui.select({ "Run", "Remove" }, {
                    prompt = "What do you want to do with " .. selection.display .. "?",
                },
                function(choice)
                    if choice == "Run" then
                        vim.cmd("terminal docker run -it --rm " .. selection.display)
                    elseif choice == "Remove" then
                        vim.fn.jobstart({ "docker", "rmi", selection.value.id }, {
                            stdout_buffered = true,
                            on_stdout = function(_, data)
                                vim.notify(table.concat(data, "\n"), vim.log.levels.INFO, { title = "Image Removed" })
                            end,
                        })
                    end
                end)
            end)
            return true
        end,
        sorter = config.generic_sorter(opts),
        previewer = previewers.new_buffer_previewer({
            title = "Docker Image Details",
            define_preview = function(self, entry)
                if not entry or not entry.value then
                    vim.apui.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "No details available" })
                    return
                end
                local details = entry.value
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {
                    "ID: " .. (details.id or "N/A"),
                    "Size: " .. (details.size or "N/A"),
                    "",
                    "Raw Output: " .. (details.raw or "N/A"),
                })
            end,
        })
    }):find()
end

M.setup()

return M
