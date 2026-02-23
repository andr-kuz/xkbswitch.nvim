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

## Hyprland Linux
Unlike the master repository plugin, this one is intended for use with Hyprland only and therefore does not require any additional dependencies.

1. Install this plugin
<table>
<tr>
  <th> Packer </th>
  <th> Lazy (~/.config/nvim/lua/plugins/xkbswitch.lua) </th>
  <th> Dein </th>
</tr>
<tr>
<td>

```lua
use 'ivanesmantovich/xkbswitch.nvim'
```

</td>
<td>

```lua
return { 
    {'ivanesmantovich/xkbswitch.nvim'} 
}
```

</td>
<td>

```lua
call dein#add('ivanesmantovich/xkbswitch.nvim')
```

</td>
</tr>
</table>

2. Add the setup line to your config
```lua
require('xkbswitch').setup()
```

## With Tmux
If you use Neovim inside of Tmux add this line to your `.tmux.conf`
```tmux
set -g focus-events on
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
