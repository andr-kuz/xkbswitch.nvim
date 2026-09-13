local Hyprland = {}
Hyprland.__index = Hyprland

function Hyprland:new()
    local instance = setmetatable({}, self)
    instance.us_layout_name = nil
    instance.us_layout_index = nil
    instance:init()
    return instance
end

function Hyprland:init()
    local hyprland_devices_json = vim.fn.system('hyprctl devices -j')
    local hyprland_devices = vim.json.decode(hyprland_devices_json)
    for _, keyboard in pairs(hyprland_devices.keyboards) do
        if keyboard.main == true then
            self.us_layout_name = keyboard.name
            local index = 0
            for word in string.gmatch(keyboard.layout, '([^,]+)') do
                if word:match('^us') then
                    self.us_layout_index = index
                end
                index = index + 1
            end
            break
        end
    end
end

function Hyprland:get_current_layout_index()
    return vim.fn.system("hyprctl devices | sed -n '/^[[:space:]]*" .. self.us_layout_name .. "$/,/active layout index:/ { /active layout index:/ s/.*:[[:space:]]*//p }'")
end

function Hyprland:set_layout(layout_index)
    vim.fn.system('hyprctl switchxkblayout '.. self.us_layout_name ..' ' .. layout_index)
end

local Niri = {}
Niri.__index = Niri

function Niri:new()
    local instance = setmetatable({}, self)
    instance.us_layout_name = nil
    instance.us_layout_index = nil
    instance:init()
    return instance
end

function Niri:init()
    local niri_layouts_json = vim.fn.system('niri msg --json keyboard-layouts')
    local niri_layouts = vim.json.decode(niri_layouts_json)
    for index, name in ipairs(niri_layouts.names) do
        if name:match('^English') then
            self.us_layout_name = name
            self.us_layout_index = index - 1
        end
    end
end

function Niri:get_current_layout_index()
    local output = vim.fn.system("niri msg keyboard-layouts")
    return output:match("%*%s+(%d+)")
end

function Niri:set_layout(layout_index)
    vim.fn.system('niri msg action switch-layout ' .. layout_index)
end


return {
  hyprland = Hyprland,
  niri = Niri,
}
