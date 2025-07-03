<div align="center">
  <p>
    <img src="assets/logo.png" align="center" alt="Logo" />
  </p>
</div>

Do you have more than one keyboard layout and constantly switching back to English just to be able to move?\
Stop it, get some help!\
With **xkbswitch.nvim** you can write comments/notes/documents in your language of choice, press `Esc` to enter Normal mode and instantly be ready to make your next move.\
Plugin saves your actual layout before switching to English. The next time you enter Insert mode you will have your last saved layout.\
**It also works with focus.** When Neovim loses focus plugin switches your layout to the last saved one. When Neovim gets focus plugin saves your layout, which you could've changed in another window and switches to English **only if** you need it. ([Logic](#about))\
Now you need to switch your layout only when you need to type something in a different language! That's the way it always should have been.

## Linux / Unix (Wayland and Hyprland)
In most cases you do not need to install anything, just make sure you can run `hyprctl` and have `jq` installed.
Then you need to detect your active keyboard running `hyprctl devices -j | jq -r '.keyboards[]'` and check which of them react to layout changing.
Put its name in a settings. Mine is `keyd-virtual-keyboard` because I use `keyd` so using `lazy` I configure it this way:

```lua
return {
  'andr-kuz/xkbswitch.nvim',
  config = function()
    require('xkbswitch').setup({
      hyprctl_active_keyboard_name = 'keyd-virtual-keyboard'
    })
  end
}
```

## About
This plugin uses autocommands to 'listen' when you are entering and exiting Insert mode, or when Neovim gets or loses focus, and libcalls to change your layout.

* **When leaving Insert Mode:**
1) Save the current layout
2) Switch to the US layout

* **When entering Insert Mode:**
1. Switch to the previously saved layout

* **When Neovim gets focus:**
1. Save the current layout
2. Switch to the US layout if Normal Mode or Visual Mode is the current mode

* **When Neovim loses focus:**
1. Switch to the previously saved layout
