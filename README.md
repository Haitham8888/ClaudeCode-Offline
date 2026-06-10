# Claude Code Offline

Run Claude Code v2.1.170 fully offline with zero internet, zero login, and zero authentication, backed by a local SGLang server serving DeepSeek V4 Flash.

## Overview

This package enables complete offline operation of Anthropic's Claude Code CLI by redirecting all API traffic from Anthropic's cloud servers to a local SGLang instance. No proxy, no translation layer, and no internet connection are required after initial setup.

### How It Works

```
Client Machine                          SGLang Server (RHEL / Podman)
+-------------------+                   +---------------------------+
|  Claude Code CLI  | --- HTTP:30000 -> |  /v1/messages endpoint   |
|  (REPL / Batch)   |                   |  DeepSeek V4 Flash       |
|                   | <--- JSON -------- |  CUDA 13                 |
|  Tools:           |                   +---------------------------+
|  Bash, Edit,      |
|  Read, Glob, ...  |
+-------------------+
        |
        v
+-------------------+
|  Project Files    |  read/write locally
+-------------------+

  No Internet    No Login    No Telemetry
```

## Requirements

### Windows
- Windows 10 (1903+) or Windows 11
- Git for Windows ([git-scm.com](https://git-scm.com))
- Network access to the SGLang server on port 30000

### Linux (RHEL / Fedora / CentOS / Rocky Linux)
- RHEL 8+ or equivalent
- Git: `sudo dnf install git`
- Network access to the SGLang server on port 30000

### SGLang Server (RHEL 10 with Podman)
- DeepSeek V4 Flash running in a Podman container
- Port 30000 exposed on the local network
- `/v1/messages` endpoint enabled (SGLang PR #18630)

## Package Structure

```
ClaudeCode-Offline-Package/
  config/
    settings.json                     Pre-built config blocking all outbound traffic
  scripts/
    setup-env-windows.ps1             Windows PowerShell environment setup
    setup-env-linux.sh                Linux Bash environment setup
  windows/
    claude.exe                        Claude Code binary (242 MB, excluded from git)
    install-offline.bat               Windows offline installer
  linux/
    claude                            Claude Code binary (247 MB, excluded from git)
    install-offline.sh                Linux offline installer
  index.html                          Offline setup guide (Arabic)
  README.md                           This file
```

## Quick Start

Set three environment variables and launch Claude Code:

### Windows (CMD)
```cmd
set ANTHROPIC_BASE_URL=http://TBD:30000
set ANTHROPIC_API_KEY=sk-offline
set ANTHROPIC_DEFAULT_HAIKU_MODEL=DeepSeek-V4-Flash
set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
claude --model DeepSeek-V4-Flash
```

### Windows (PowerShell)
```powershell
$env:ANTHROPIC_BASE_URL = "http://TBD:30000"
$env:ANTHROPIC_API_KEY = "sk-offline"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "DeepSeek-V4-Flash"
$env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
claude --model DeepSeek-V4-Flash
```

### Linux
```bash
export ANTHROPIC_BASE_URL=http://TBD:30000
export ANTHROPIC_API_KEY=sk-offline
export ANTHROPIC_DEFAULT_HAIKU_MODEL=DeepSeek-V4-Flash
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
claude --model DeepSeek-V4-Flash
```

Replace `TBD` with your SGLang server's actual IP address.

## Installation

### Windows
1. Install Git for Windows if not already installed:
   ```
   winget install Git.Git
   ```
2. Run the offline installer as Administrator:
   ```
   .\windows\install-offline.bat
   ```
   Or install manually:
   ```
   mkdir -Force "$env:USERPROFILE\.local\bin"
   copy windows\claude.exe "$env:USERPROFILE\.local\bin\"
   [Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$env:USERPROFILE\.local\bin", [EnvironmentVariableTarget]::User)
   mkdir -Force "$env:USERPROFILE\.claude"
   copy config\settings.json "$env:USERPROFILE\.claude\"
   ```

### Linux
1. Install prerequisites:
   ```
   sudo dnf install git curl
   ```
2. Run the offline installer:
   ```
   chmod +x linux/install-offline.sh
   ./linux/install-offline.sh
   ```
   Or install manually:
   ```
   mkdir -p ~/.local/bin
   cp linux/claude ~/.local/bin/
   chmod +x ~/.local/bin/claude
   mkdir -p ~/.claude
   cp config/settings.json ~/.claude/settings.json
   ```

## Configuration

### Persistent Settings (~/.claude/settings.json)

All environment variables can be placed in the settings file for persistence:

```json
{
  "permissions": {
    "allow": ["Bash(*)", "Read(*)", "Write(*)", "Edit(*)"]
  },
  "env": {
    "ANTHROPIC_BASE_URL": "http://TBD:30000",
    "ANTHROPIC_API_KEY": "sk-offline",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "DeepSeek-V4-Flash",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "DISABLE_AUTOUPDATER": "1",
    "CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY": "1"
  },
  "fallbackModel": ["DeepSeek-V4-Flash"]
}
```

### Environment Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `ANTHROPIC_BASE_URL` | Yes | Redirects all Claude Code API requests from Anthropic's servers to the local SGLang server. This is the primary enabler of offline operation. |
| `ANTHROPIC_API_KEY` | Yes | Dummy API key (e.g. sk-offline). SGLang does not validate it. Required to prevent the Claude Code login prompt. |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Recommended | Blocks telemetry, error reports, update checks, surveys, and all HTTP requests unrelated to the API. |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Recommended | Specifies the model used for background tasks (session naming, summarization, agent naming). Critical for multi-agent offline operation. Without it, Claude Code attempts to use Anthropic's Haiku model and fails. Set to the same local model name. |
| `DISABLE_AUTOUPDATER` | Recommended | Disables automatic update checks. |
| `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY` | Optional | Set to `1` to populate the `/model` picker from the local server's `/v1/models` endpoint. Useful when the server exposes multiple models. |
| `MAX_THINKING_TOKENS` | Optional | Set to `0` to disable extended thinking entirely. Useful for local models that do not support thinking. |
| `DISABLE_TELEMETRY` | Optional | Prevents usage data transmission. |
| `DO_NOT_TRACK` | Optional | Equivalent to DISABLE_TELEMETRY. |
| `CLAUDE_CODE_DISABLE_OFFICIAL_MARKETPLACE_AUTOINSTALL` | Optional | Prevents automatic installation of official marketplace add-ons. |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Optional | Disables background tasks. |
| `DISABLE_LOGIN_COMMAND` | Optional | Hides the `/login` command entirely. |
| `CLAUDE_CODE_SIMPLE` | Optional | Disables auto-discovery of hooks, plugins, MCP servers, and skills. Automatically enables `--print` mode. |
| `ENABLE_TOOL_SEARCH` | Optional | Controls MCP tool search behavior. Set to `false` to load all tools upfront. |

### Additional Settings (settings.json, v2.1.166+)

| Setting | Description |
|---------|-------------|
| `fallbackModel` | Configures up to 3 fallback models tried in order when the primary model is overloaded or unavailable. Essential for local setups. |
| `disableBundledSkills` | Hides bundled skills, workflows, and built-in slash commands. Requires v2.1.169+. |

## Running Modes

| Mode | Command | Description |
|------|---------|-------------|
| Interactive (REPL) | `claude --model DeepSeek-V4-Flash` | Full multi-turn conversational session. Best for development. |
| Single command | `claude --bare -p "..."` | One question, one response. Suitable for scripts and pipelines. |
| STDIN pipe | `echo "..." \| claude --bare` | Pass text through a pipe. |
| No-permission mode | `claude --model DeepSeek-V4-Flash --permission-mode bypassPermissions` | Executes commands without prompting for each action. |

Note: `--bare` disables advanced features such as hooks, LSP, plugin sync, and keychain reads. Omit `--bare` if these features are needed.

## Multi-Agent Operation (Fully Offline)

Claude Code supports running multiple sub-agents in parallel, all sharing the same connection to the local SGLang server. All 9 bundled agents and any custom agents use the same local model.

### Workflow

1. **Main session** serves as the control point for delegating tasks.
2. **`/fork [directive]`** creates a background sub-agent that inherits the current conversation context. The agent works immediately while you continue your original session.
3. **`/background [prompt]`** sends the entire current session to the background, freeing the terminal.
4. **Multiple parallel agents** can be created by issuing `/fork` multiple times. Each agent sends its own requests to the local API.
5. **Agent management** from another terminal: `claude agents` lists all background sessions.

### Practical Example

```cmd
set ANTHROPIC_BASE_URL=http://TBD:30000
set ANTHROPIC_API_KEY=sk-offline
set ANTHROPIC_DEFAULT_HAIKU_MODEL=DeepSeek-V4-Flash
claude --model DeepSeek-V4-Flash

# Inside the REPL session:

# Delegate architecture design to code-architect:
/fork Act as code-architect to design an authentication system architecture supporting JWT and OAuth2. Write the plan to AUTH-ARCH.md

# Delegate code review to code-reviewer (parallel):
/fork Act as code-reviewer and review all auth files in src/auth/. Write findings to CODE-REVIEW.md

# Delegate security audit to security-auditor (parallel):
/fork Act as security-auditor and analyze potential vulnerabilities in src/auth/. Write report to SECURITY.md

# Results return to your main conversation automatically when each agent completes.
```

### Important Notes for Offline Multi-Agent Use

- All agents share the same local SGLang API -- no external connections.
- Each agent has an independent context. `/fork` gives each agent a copy of the conversation at the point of delegation.
- Multiple concurrent agents send simultaneous requests to SGLang. If performance degrades, reduce concurrent agents or use `/compact` to shorten context.
- No API costs -- since the server is local, there are no usage limits.
- **`ANTHROPIC_DEFAULT_HAIKU_MODEL` must be set** to the same local model name. Without it, background tasks (agent naming, session summarization) attempt to reach Anthropic's cloud Haiku model and fail silently.

## Bundled Agents

The following agents are pre-installed from the official marketplace and stored locally:

- **code-architect** -- Project architecture design and code analysis
- **code-explorer** -- Codebase exploration and understanding
- **code-reviewer** -- Code review and improvement suggestions
- **legacy-analyst** -- Legacy code analysis
- **security-auditor** -- Security code review
- **test-engineer** -- Test writing and code testing
- **code-simplifier** -- Code simplification and readability improvement
- **agent-creator** -- New agent creation
- **conversation-analyzer** -- Conversation analysis

## Verification

### 1. Server Connectivity
```bash
curl http://TBD:30000/v1/models
```
Expected response:
```json
{
  "object": "list",
  "data": [
    { "id": "DeepSeek-V4-Flash", "object": "model" }
  ]
}
```

### 2. Claude Code Version
```bash
claude --version
```
Expected: `2.1.170`

### 3. Single Command Test
```cmd
set ANTHROPIC_BASE_URL=http://TBD:30000
set ANTHROPIC_API_KEY=sk-offline
set ANTHROPIC_DEFAULT_HAIKU_MODEL=DeepSeek-V4-Flash
set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
claude --bare -p "write hello"
```

### 4. Interactive REPL Test
```cmd
set ANTHROPIC_BASE_URL=http://TBD:30000
set ANTHROPIC_API_KEY=sk-offline
set ANTHROPIC_DEFAULT_HAIKU_MODEL=DeepSeek-V4-Flash
set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
claude --model DeepSeek-V4-Flash
```

### 5. Agents Test
Inside a Claude Code session, type `/agents` to list available agents.

## SGLang Server Setup

Start DeepSeek V4 Flash on RHEL with Podman:

```bash
podman run --gpus all \
  --shm-size 32g \
  -p 30000:30000 \
  -v /path/to/models:/models:Z \
  --ipc=host \
  lmsysorg/sglang:latest \
  python3 -m sglang.launch_server \
    --model-path /models/DeepSeek-V4-Flash \
    --tp 4 \
    --host 0.0.0.0 \
    --port 30000 \
    --tool-call-parser deepseekv3
```

The `--tool-call-parser deepseekv3` flag is required for Claude Code tool-calling support (Bash, Edit, Read, etc.).

### Server Test
```bash
# List models
curl http://TBD:30000/v1/models

# Test messages endpoint (Anthropic API format)
curl -X POST http://TBD:30000/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: sk-offline" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "DeepSeek-V4-Flash",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "Say hello"}]
  }'
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `claude` is not recognized | Open a new terminal. If the problem persists, manually add `%USERPROFILE%\.local\bin` to PATH. |
| Model not available | Run `curl http://[IP]:30000/v1/models` to list available models, then use the correct name with `--model`. |
| Connection refused (ECONNREFUSED) | Verify the SGLang server is running, the IP address is correct, and port 30000 is allowed through the firewall. |
| Login prompt appears | Ensure `ANTHROPIC_BASE_URL` points to your local server and `ANTHROPIC_API_KEY` is set to a non-empty dummy value. |
| Window opens and closes immediately (Windows) | The SGLang server is unreachable. Verify server availability before launching Claude Code, or use `--bare` mode. |
| `/doctor` unavailable | `/doctor` does not work with `--bare`. Use it in interactive mode (without `--bare`). |

## What Works Offline

- All slash commands (except WebFetch and WebSearch, which require internet)
- All sub-agents (Agents) via the local API
- All built-in tools: Bash, Edit, Read, Glob, Grep, TodoWrite, LS, NotebookRead
- Plugin management (`/plugin list`)
- Session management (`/clear`, `/resume`, `/branch`, `/background`, `/compact`, `/context`)
- Project commands (`/cd`, `/add-dir`, `/diff`, `/init`)
- Agent management (`/agents`, `/fork`)
- Configuration (`/config`, `/color`, `/doctor`, `/help`, `/release-notes`)

## What Does Not Work Offline

- **WebFetch** -- Fetches content from URLs (requires internet)
- **WebSearch** -- Web search (requires internet)
- **External MCP integrations** -- GitHub, GitLab, Linear, Discord (require connectivity to their services)

## License

This package bundles Claude Code v2.1.170, which is subject to Anthropic's terms of service. All configuration files and scripts are provided for offline setup purposes only.

## Repository

GitHub: [https://github.com/Haitham8888/ClaudeCode-Offline](https://github.com/Haitham8888/ClaudeCode-Offline) (private)

Binary files (`windows/claude.exe` and `linux/claude`) are excluded from git due to size (242 MB / 247 MB). Copy them manually after pulling the repository.
