local M = {}

-- Default parameters
M.events_get_focus = {'FocusGained', 'CmdlineLeave'}

-- nvim_create_autocmd shortcut
local autocmd = vim.api.nvim_create_autocmd

local manager = nil
local managers = require('tiling_managers')

if vim.env.HYPRLAND_INSTANCE_SIGNATURE then
    manager = managers.hyprland:new()
elseif vim.env.NIRI_SOCKET then
    manager = managers.niri:new()
end

if manager == nil then
    error("Could not detect your tiling manager")
end

local saved_layout = manager:get_current_layout_index()

function M.setup(opts)

   -- Parse provided options
    opts = opts or {}
    if opts.events_get_focus then
        M.events_get_focus = opts.events_get_focus
    end

    -- When leaving Insert Mode:
    -- 1. Save the current layout
    -- 2. Switch to the US layout
    autocmd(
        'InsertLeave',
        {
            pattern = "*",
            callback = function()
                vim.schedule(function()
                    saved_layout = manager:get_current_layout_index()
                    manager:set_layout(manager.us_layout_index)
                end)
            end
        }
    )

    -- When Neovim gets focus:
    -- 1. Save the current layout
    -- 2. Switch to the US layout if Normal Mode or Visual Mode is the current mode
    autocmd(
        M.events_get_focus,
        {
            pattern = "*",
            callback = function()
                vim.schedule(function()
                    saved_layout = manager:get_current_layout_index()
                    local current_mode = vim.api.nvim_get_mode().mode
                    if current_mode == "n" or current_mode == "no" or current_mode == "v" or current_mode == "V" or current_mode == "^V" then
                        manager:set_layout(manager.us_layout_index)
                    end
                end)
            end
        }
    )

    -- When Neovim loses focus
    -- When entering Insert Mode:
    -- 1. Switch to the previously saved layout
    autocmd(
        {'FocusLost', 'InsertEnter'},
        {
            pattern = "*",
            callback = function()
                vim.schedule(function()
                    manager:set_layout(saved_layout)
                end)
            end
        }
    )
end

return M
