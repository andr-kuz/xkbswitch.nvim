local M = {}

-- Default parameters
M.events_get_focus = {'FocusGained', 'CmdlineLeave'}

-- nvim_create_autocmd shortcut
local autocmd = vim.api.nvim_create_autocmd

local hyprland_main_keyboard_name = nil
local user_us_layout_variation = nil

if vim.env.HYPRLAND_INSTANCE_SIGNATURE then
    local hyprland_devices_json = vim.fn.system('hyprctl devices -j')
    local hyprland_devices = vim.json.decode(hyprland_devices_json)
    for _, keyboard in pairs(hyprland_devices.keyboards) do
        if keyboard.main == true then
            hyprland_main_keyboard_name = keyboard.name
            local index = 0
            for word in string.gmatch(keyboard.layout, '([^,]+)') do
                if word:match('^us') then
                    user_us_layout_variation = index
                end
                index = index + 1
            end
            break
        end
    end
end

if hyprland_main_keyboard_name == nil then
    error("Could not detect `hyprland` or its main keyboard with `hyprctl devices -j`")
end

if user_us_layout_variation == nil then
    error("Could not detect `us` layout of `" .. hyprland_main_keyboard_name .. "` in `hyprctl devices -j`")
end

local function get_current_layout()
    return vim.fn.system("hyprctl devices | sed -n '/^[[:space:]]*" .. hyprland_main_keyboard_name .. "$/,/active layout index:/ { /active layout index:/ s/.*:[[:space:]]*//p }'")
end

local saved_layout = get_current_layout()

local function set_layout(layout_index)
    vim.fn.system('hyprctl switchxkblayout '.. hyprland_main_keyboard_name ..' ' .. layout_index)
end

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
                    saved_layout = get_current_layout()
                    set_layout(user_us_layout_variation)
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
                    saved_layout = get_current_layout()
                    local current_mode = vim.api.nvim_get_mode().mode
                    if current_mode == "n" or current_mode == "no" or current_mode == "v" or current_mode == "V" or current_mode == "^V" then
                        set_layout(user_us_layout_variation)
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
                    set_layout(saved_layout)
                end)
            end
        }
    )
end

return M
