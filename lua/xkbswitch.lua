local M = {}

local function exec(command)
    local cmd = command
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    return result:gsub("%s+$", "")  -- Trim trailing whitespace
end

local function get_current_layout()
    local cmd = string.format(
        "hyprctl devices -j | jq -r '.keyboards[] | select(.name == \"%s\") .active_keymap'",
        M.hyprctl_active_keyboard_name
    )
    local result = exec(cmd)
    return result:lower():sub(1, 2)
end

M.events_get_focus = {'FocusGained', 'CmdlineLeave'}
M.hyprctl_active_keyboard_name = nil
M.en_layout_name = nil
M.available_layouts = {}

local autocmd = vim.api.nvim_create_autocmd

local function set_layout(layout_code)
    -- Find the index of the layout in available_layouts
    local layout_index = nil
    for i, available_layout in ipairs(M.available_layouts) do
        if available_layout == layout_code then
            layout_index = i - 1  -- hyprctl uses 0-based index
            break
        end
    end

    if not layout_index then
        error(string.format("Layout '%s' not found in available layouts", layout_code))
    end

    -- Execute the layout switch command
    local cmd = string.format(
        'hyprctl switchxkblayout %s %d',
        M.hyprctl_active_keyboard_name,
        layout_index
    )
    exec(cmd)
end

function M.setup(opts)

  if not opts or not opts.hyprctl_active_keyboard_name then
    error("opts.hyprctl_active_keyboard_name must be set")
  end

  if opts.events_get_focus then
      M.events_get_focus = opts.events_get_focus
  end

  M.hyprctl_active_keyboard_name = opts.hyprctl_active_keyboard_name
  M.saved_layout = get_current_layout()

  local cmd = string.format(
    "hyprctl devices -j | jq -r '.keyboards[] | select(.name == \"%s\") .layout'",
    M.hyprctl_active_keyboard_name
  )
  local result = exec(cmd)
  
  for layout in string.gmatch(result, "([^,]+)") do
    local trimmed_layout = layout:match("^%s*(.-)%s*$")  -- Trim whitespace
    -- Check for English layout
    if not M.en_layout_name and (trimmed_layout:lower():match("^us") or trimmed_layout:lower():match("^en")) then
      M.en_layout_name = 'en'
      trimmed_layout = 'en'
    end

    table.insert(M.available_layouts, trimmed_layout)
  end
  
  if not M.en_layout_name then
    error(string.format(
      "Error occurred: could not find the English layout. Check your layout list executing: hyprctl devices -j | jq -r '.keyboards[] | select(.name == \"%s\") .layout'",
      opts.hyprctl_active_keyboard_name
    ))
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
                  M.saved_layout = get_current_layout()
                  set_layout(M.en_layout_name)
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
                  M.saved_layout = get_current_layout()
                  local current_mode = vim.api.nvim_get_mode().mode
                  if current_mode == "n" or current_mode == "no" or current_mode == "v" or current_mode == "V" or current_mode == "^V" then
                      set_layout(M.en_layout_name)
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
                  set_layout(M.saved_layout)
              end)
          end
      }
)
end

return M
