#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo " Installing Antigravity CLI as Default Omarchy Agent      "
echo "=========================================================="

# 1. Ensure ~/.local/bin exists
mkdir -p "$HOME/.local/bin"

# 2. Copy the agent launcher wrapper
cp "$SCRIPT_DIR/bin/omarchy-agent" "$HOME/.local/bin/omarchy-agent"
chmod +x "$HOME/.local/bin/omarchy-agent"
echo "[✓] Installed ~/.local/bin/omarchy-agent"

# 3. Set the default agent to agy
mkdir -p "$HOME/.config/omarchy/defaults"
echo "agy" > "$HOME/.config/omarchy/defaults/agent"
echo "[✓] Configured ~/.config/omarchy/defaults/agent -> agy"

# 4. Check Hyprland keybinding
BINDINGS_LUA="$HOME/.config/hypr/bindings.lua"
if [ -f "$BINDINGS_LUA" ]; then
    if ! grep -q "omarchy-agent" "$BINDINGS_LUA"; then
        echo "" >> "$BINDINGS_LUA"
        echo "-- Overrides Omarchy's default agent runner to use ~/.local/bin/omarchy-agent (supports Antigravity / agy)" >> "$BINDINGS_LUA"
        echo 'o.bind("SUPER + SHIFT + CTRL + A", "Agent", (os.getenv("HOME") or "/home/matias") .. "/.local/bin/omarchy-agent --pick")' >> "$BINDINGS_LUA"
        echo "[✓] Added SUPER+SHIFT+CTRL+A keybinding to ~/.config/hypr/bindings.lua"
    else
        echo "[✓] Hyprland keybinding already configured in $BINDINGS_LUA"
    fi
fi

# 5. Verify agy binary is available
if ! command -v agy &>/dev/null; then
    echo "[!] Warning: 'agy' command was not found in your PATH."
    echo "    Make sure Google Antigravity is installed at ~/.local/bin/agy or in your system PATH."
else
    echo "[✓] Antigravity CLI detected: $(which agy)"
fi

echo ""
echo "=========================================================="
echo " Installation complete!                                  "
echo " You can now launch Antigravity with:                     "
echo "   - Keybinding: SUPER + SHIFT + CTRL + A                 "
echo "   - CLI:        omarchy-agent                            "
echo "   - With prompt: omarchy agent prompt \"your request\"     "
echo "=========================================================="
