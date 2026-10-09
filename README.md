# Using Google Antigravity CLI (`agy`) as the Default Omarchy Linux Agent

A comprehensive guide, drop-in replacement scripts, and upstream patch to replace the **deprecated Google Gemini CLI** with **Google Antigravity CLI (`agy`)** as the default operating system coding agent in **Omarchy Linux**.

---

## Background & Architecture

[**Omarchy**](https://github.com/basecamp/omarchy) (created by DHH / 37signals) is an opinionated Arch Linux distribution that includes deep desktop integration for AI coding agents:
- System command: `omarchy agent`
- Setting default: `omarchy default agent <name>` or via the desktop menu (`SUPER + SPACE` -> setup default agent)
- Desktop shortcut: `SUPER + SHIFT + CTRL + A` opens a floating dedicated TUI window (`omarchy-launch-tui`)

In upstream Omarchy, the Google option was wired to `gemini` ([Gemini CLI](https://github.com/google-gemini/gemini-cli)):
```bash
gemini)
  command=(gemini --yolo)
  [[ -n ${prompt:-} ]] && command+=(--prompt-interactive "$prompt")
  ;;
```

However, **Google has deprecated Gemini CLI** in favor of **Google Antigravity CLI (`agy`)**, the next-generation autonomous agent platform featuring advanced tool invocation, subagent orchestration, MCP integration, and automated project workflows.

---

## Comparison: Gemini CLI vs. Antigravity CLI (`agy`)

| Feature | Legacy Gemini CLI (`gemini`) | Google Antigravity CLI (`agy`) |
| :--- | :--- | :--- |
| **Status** | ⚠️ **Deprecated** | ✅ **Active & Modern Standard** |
| **Omarchy Launch Flags** | `gemini --yolo` | `agy --dangerously-skip-permissions --mode accept-edits` |
| **Interactive Prompt Seeding** | `--prompt-interactive "<prompt>"` | `--prompt-interactive "<prompt>"` |
| **Autonomous Multi-Step Execution** | Basic script runner | Full agentic loop with self-correction & plan artifacts |
| **Subagents & Delegation** | ❌ None | ✅ Eager & lazy subagent spawning (`invoke_subagent`) |
| **MCP Server Support** | ❌ None | ✅ Native Model Context Protocol (MCP) clients |
| **Workspace Sandboxing** | Minimal | ✅ Intelligent workspace & trust boundary isolation |

---

## How It Works in Omarchy

The integration uses three configuration layers that cleanly override system defaults without modifying read-only package files:

1. **Default Agent Setting** (`~/.config/omarchy/defaults/agent`):
   Contains `agy`, signaling to Omarchy that Antigravity is the preferred agent.

2. **User-Space Launcher Wrapper** (`~/.local/bin/omarchy-agent`):
   Placed in `~/.local/bin/` so it shadows `/usr/bin/omarchy-agent`. It intercepts the launch when the agent is `agy` or `antigravity`:
   ```bash
   if [[ "$agent" == "agy" || "$agent" == "antigravity" ]]; then
     # Avoids home directory trust prompts by defaulting to ~/Work if present
     [[ $PWD == "$HOME" && -d $HOME/Work ]] && cd "$HOME/Work"

     command=(agy --dangerously-skip-permissions --mode accept-edits)
     [[ -n ${prompt:-} ]] && command+=(--prompt-interactive "$prompt")

     if [[ $inline == "true" ]]; then
       exec "${command[@]}"
     else
       exec omarchy-launch-tui --app-id=org.omarchy.agent "${command[@]}"
     fi
   fi
   ```

3. **Desktop Shortcut Override** (`~/.config/hypr/bindings.lua`):
   Binds `SUPER + SHIFT + CTRL + A` directly to the custom agent launcher:
   ```lua
   o.bind("SUPER + SHIFT + CTRL + A", "Agent", (os.getenv("HOME") or "/home/matias") .. "/.local/bin/omarchy-agent --pick")
   ```

---

## Quickstart Installation

### 1. Clone this Repository
```bash
git clone https://github.com/maitas44/Omarchy-Antigravity-Agent.git
cd Omarchy-Antigravity-Agent
```

### 2. Run the Installer
```bash
chmod +x install.sh
./install.sh
```

The script will:
1. Copy `bin/omarchy-agent` to `~/.local/bin/omarchy-agent`.
2. Write `agy` to `~/.config/omarchy/defaults/agent`.
3. Add the Hyprland keybinding to `~/.config/hypr/bindings.lua`.
4. Verify the `agy` binary exists on your `PATH`.

---

## Usage

* **Desktop Shortcut**: Press `SUPER + SHIFT + CTRL + A` to open Antigravity CLI in a themed floating terminal.
* **Terminal Launch**: Run `omarchy agent` or `omarchy-agent`.
* **Inline Launch**: Run `omarchy agent --inline` (runs directly in your current terminal session).
* **Launch with Initial Prompt**: 
  ```bash
  omarchy agent prompt "Analyze git status and fix any syntax errors"
  ```

---

## Upstream Omarchy Patch

To natively integrate Antigravity into [basecamp/omarchy](https://github.com/basecamp/omarchy), apply [`patches/omarchy-upstream-antigravity.patch`](patches/omarchy-upstream-antigravity.patch):

### Changes to `bin/omarchy-default-agent`:
```diff
--- a/bin/omarchy-default-agent
+++ b/bin/omarchy-default-agent
@@ -2,7 +2,7 @@
-# omarchy:args=[pi|omp|opencode|claude|codex|grok|gemini|openclaw|hermes|copilot|crush|cursor-agent|muse]
+# omarchy:args=[pi|omp|opencode|claude|codex|grok|agy|openclaw|hermes|copilot|crush|cursor-agent|muse]
@@ -31,3 +31,4 @@
-gemini | gemini-cli) agent="gemini"; name="Gemini" ;;
+agy | antigravity) agent="agy"; name="Antigravity" ;;
+gemini | gemini-cli) agent="agy"; name="Antigravity" ;; # Legacy alias for deprecated Gemini CLI
```

### Changes to `bin/omarchy-agent`:
```diff
--- a/bin/omarchy-agent
+++ b/bin/omarchy-agent
@@ -61,4 +61,4 @@
-gemini)
-  command=(gemini --yolo)
+agy|antigravity|gemini)
+  command=(agy --dangerously-skip-permissions --mode accept-edits)
   [[ -n ${prompt:-} ]] && command+=(--prompt-interactive "$prompt")
   ;;
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.
