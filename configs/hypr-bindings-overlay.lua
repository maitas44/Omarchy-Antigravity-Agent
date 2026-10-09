-- Add to ~/.config/hypr/bindings.lua
-- Overrides Omarchy's default agent runner keybinding to invoke ~/.local/bin/omarchy-agent (supporting Antigravity / agy)
o.bind("SUPER + SHIFT + CTRL + A", "Agent", (os.getenv("HOME") or "/home/matias") .. "/.local/bin/omarchy-agent --pick")
