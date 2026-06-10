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

### Multi-Agent as a Development Team

One of the most powerful aspects of running Claude Code offline with multiple agents is that it mimics having an entire development team working for you in parallel. Each `/fork` creates an independent worker with its own context, tools, and mission.

```
YOU (Session Owner / Product Owner)
  |
  |-- /fork "code-architect"          (Architect - designs the structure)
  |     Writes AUTH-ARCH.md, defines components, data flow
  |
  |-- /fork "code-reviewer"           (Senior Dev - reviews existing code)
  |     Analyzes src/auth/, writes CODE-REVIEW.md with findings
  |
  |-- /fork "security-auditor"        (Security Engineer - audits)
  |     Scans for vulnerabilities, writes SECURITY.md
  |
  |-- /fork "test-engineer"           (QA Engineer - writes tests)
  |     Creates unit tests, integration tests
  |
  |-- /fork "legacy-analyst"          (Analyst - studies old code)
  |     Documents legacy patterns, migration paths
  |
  YOU continue working in the main session while all 5 agents run concurrently.
  Each returns results automatically when done.
```

All of these agents run simultaneously on the same single local model (DeepSeek V4 Flash). They do not wait for each other, they do not block your main session, and they do not cost anything beyond the compute power of your SGLang server. You effectively scale from one developer to a team of six with a single `/fork` command each.

The key insight: a single local model is sufficient because the agents switch contexts independently. The model does not need to run multiple copies -- it processes one agent's request at a time, but each agent takes turns so quickly that from your perspective they appear to work in parallel. With SGLang's efficient batching on CUDA 13, multiple concurrent requests are handled smoothly.

### Official Confirmation from Anthropic Documentation

The Claude Code official documentation confirms this behavior explicitly:

| Aspect | Fork subagent | Named subagent (code-architect, etc.) |
|--------|--------------|--------------------------------------|
| **Model** | **Same as main session** | From the subagent's `model` field |
| **System prompt & tools** | Same as main session | From the subagent's definition |
| **Context** | Full conversation history | Fresh context |
| **Prompt cache** | Shared with main session | Separate cache |

Source: [code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents)

Key takeaways from the official documentation:

1. **Fork subagents (`/fork`)**: Inherit the **exact same model** as your main session. Every `/fork` agent sends its requests to the same `ANTHROPIC_BASE_URL` endpoint with the same model name.

2. **Named subagents** (the 9 bundled ones): Each *can* specify a model in its definition file, but in your offline setup there is only one model loaded on SGLang (DeepSeek V4 Flash). Any model name sent to the local server resolves to the loaded model. The `ANTHROPIC_BASE_URL` routes all traffic -- from the main session and every subagent -- to the same local SGLang server.

3. **`CLAUDE_CODE_FORK_SUBAGENT=1`**: This environment variable enables prompt cache sharing across parallel children, cutting token costs by up to 90% for children 2-N. It does not change the model. All children still use the same single model.

4. **With 4x H100 94GB and CUDA 13**: SGLang handles concurrent requests through efficient CUDA batching. The server queues incoming requests and processes them in parallel batches. You can comfortably run 10-20+ agents simultaneously on this hardware.

**Bottom line: one model (DeepSeek V4 Flash) is enough to run an entire team of agents -- main session, all 9 bundled agents, plus unlimited custom agents and forks. The official documentation confirms this architecture.**

## Project Context (CLAUDE.md)

### What is CLAUDE.md

`CLAUDE.md` is a Markdown file placed in the root of your project that serves as a persistent instruction set for Claude Code. Every time you open a session in that project directory, Claude reads this file and uses it as context for understanding your project's conventions, architecture, preferences, and guidelines.

Think of it as a **per-project system prompt** that you control. It is the most effective way to make Claude Code work the way you want without repeating instructions every session.

### How it Works

- Place `CLAUDE.md` in the root of your Git repository.
- Claude reads it automatically when a session starts in that directory.
- The file content is injected into the system prompt, so Claude follows it throughout the session.
- It persists across `/clear` (new sessions in the same project still read it).
- Changes to `CLAUDE.md` take effect on the next session start.
- Use `/init` to create one interactively, or create it manually.

### What to Put in CLAUDE.md

A well-crafted CLAUDE.md typically includes:

| Category | Examples |
|----------|----------|
| **Tech stack** | Languages, frameworks, runtime versions, package manager |
| **Code conventions** | Naming conventions, file structure, import style, formatting rules |
| **Testing requirements** | Test framework, coverage expectations, where tests live |
| **Build & run commands** | How to build, test, lint, format, deploy |
| **Project structure** | Purpose of each directory, key files, architecture decisions |
| **Preferences** | Preferred libraries, patterns to avoid, coding style |
| **Offline-specific notes** | Local API endpoints, model name, environment variables |

### Best Practices

1. **Be specific, not generic.** Instead of "write clean code", specify "use early returns, max 80 chars per line, PascalCase for types."
2. **Include exact commands.** `npm run test`, `cargo build --release`, `python -m pytest tests/` -- so Claude can run them.
3. **Keep it concise.** Aim for 50-150 lines. Too much context dilutes focus.
4. **Update it as the project evolves.** Outdated CLAUDE.md misleads more than it helps.
5. **Use `/init` for guided setup.** Set `CLAUDE_CODE_NEW_INIT=1` to enable the interactive init wizard that walks you through creating profiles, skills, and hooks.

### Example CLAUDE.md

```markdown
# Project: auth-service

## Tech Stack
- Go 1.23, PostgreSQL 16, Redis 7
- Framework: chi router, sqlx for DB, testify for tests
- Build: `go build ./cmd/server`
- Test: `go test ./... -race -count=1`

## Code Conventions
- Error handling: always wrap errors with context (`fmt.Errorf("fetch user %d: %w", id, err)`)
- Logging: use structured logger (zerolog), no fmt.Print
- HTTP handlers: separate handler + service + repository layers
- SQL queries: use sqlx named params `:user_id` not `$1`

## Testing
- Unit tests in `_test.go` next to source files
- Integration tests in `tests/integration/` with `//go:build integration` tag
- Run: `make test` (unit), `make test-integration` (integration)
- Aim for 80%+ coverage on business logic

## API Design
- RESTful, JSON request/response
- Auth: Bearer JWT tokens
- All endpoints prefixed with `/api/v1/`

## Project Structure
- `cmd/server/` -- main entrypoint
- `internal/handler/` -- HTTP handlers
- `internal/service/` -- business logic
- `internal/repository/` -- data access
- `migrations/` -- SQL migrations (goose)
```

### CLAUDE.md vs settings.json

| File | Scope | Purpose |
|------|-------|---------|
| `CLAUDE.md` | Per-project | Instructions, conventions, commands for Claude's behavior in that project |
| `~/.claude/settings.json` | Global / user-wide | Environment variables, permissions, API configuration, feature toggles |
| `~/.claude/projects/<project>/claude.json` | Per-project settings | Project-specific overrides for settings.json |

All three files work together. `settings.json` controls how Claude Code connects (API endpoint, keys, telemetry). `CLAUDE.md` controls what Claude does once connected (code style, commands, conventions).

### Multi-Project Tip

You can have different `CLAUDE.md` files in each project directory. Open a session in Project A and Claude follows Project A's conventions. Use `/cd <path>` to move your session to Project B, and Claude adapts to that project's CLAUDE.md mid-session (requires v2.1.169+).

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

## Browser Error Review (agent-browse MCP Server)

Claude Code can connect to your browser via an MCP server to read console logs, network requests, JavaScript errors, and page structure -- all as **text**, no vision required. This is ideal for offline setups where the model does not support screenshots.

### Why agent-browse?

| Tool | What it captures | Format | Vision needed? |
|------|-----------------|--------|:--------------:|
| `browser_console` | Console.log, warnings, errors (last 500) | Text | No |
| `browser_requests` | Network requests with status codes (last 500) | JSON | No |
| `browser_errors` | JS errors with full stack traces (last 200) | Text | No |
| `browser_snapshot` | Accessibility tree (page structure for AI) | Text | No |
| `browser_screenshot` | Full page or viewport screenshot | PNG | Yes (optional) |

Since your model reads text only, Claude will use the text-based tools (`console`, `requests`, `errors`, `snapshot`) automatically and never request screenshots.

### How it works

1. Starts a **stateful browser session** (persists across tool calls)
2. Navigates to your target URL
3. Captures console output, network requests, and errors in real time
4. You can click, fill forms, type, and interact -- then check results again

### Installation

**Option 1 -- MCP Server (recommended):**

```bash
git clone https://github.com/tollebrandon/agent-browse
cd agent-browse
npm install && npm run build
claude mcp add --transport stdio agent-browse -- node /path/to/agent-browse/dist/index.js
```

**Option 2 -- Project-level `.mcp.json`:**

Create `.mcp.json` in your project root:

```json
{
  "mcpServers": {
    "agent-browse": {
      "type": "stdio",
      "command": "node",
      "args": ["/absolute/path/to/agent-browse/dist/index.js"]
    }
  }
}
```

**Option 3 -- Global settings:**

Add the same block to `~/.claude/settings.json` under `"mcpServers"`.

### Usage Examples

Inside a Claude Code session:

> `"Open http://localhost:3000 and check the console for errors"`
>
> `"Navigate to my app, capture all network requests with status 4xx or 5xx, and report them"`
>
> `"Open the dashboard page, read the accessibility tree, and summarize the page structure"`
>
> `"Check the browser for JS errors with stack traces and suggest fixes"`

### Offline Compatibility

All communication stays local:
- The MCP server runs on your machine -- no external API calls
- Claude Code routes all AI inference to your local SGLang server via `ANTHROPIC_BASE_URL`
- The browser session is entirely local (`127.0.0.1`)
- **100% offline after initial installation**

### Comparison with other browser tools

| Feature | agent-browse | Claude in Chrome | Playwright MCP |
|---------|:------------:|:-----------------:|:--------------:|
| Console logs (structured) | 500 messages | Yes | Limited |
| Network requests + status codes | 500 requests | Metadata only | No |
| JS errors + stack traces | 200 errors | Partial | No |
| Accessibility tree | Yes | Yes | Yes |
| Stateful session | Yes | Yes | Yes |
| Headless mode | Yes | No | Yes |
| Works without vision | **Yes** | Partial | **Yes** |
| 100% offline | **Yes** | Requires extension | **Yes** |
| Chrome extension needed | No | Yes | No |

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
- **Local MCP servers** (agent-browse, Playwright MCP, and any MCP server running on localhost)

## What Does Not Work Offline

- **WebFetch** -- Fetches content from URLs (requires internet)
- **WebSearch** -- Web search (requires internet)
- **Cloud-based MCP integrations** -- GitHub, GitLab, Linear, Discord (require connectivity to their services)

**Local MCP servers** (like agent-browse for browser debugging) work 100% offline since they run on your machine and communicate with your local SGLang server.

## License

This package bundles Claude Code v2.1.170, which is subject to Anthropic's terms of service. All configuration files and scripts are provided for offline setup purposes only.

## Repository

GitHub: [https://github.com/Haitham8888/ClaudeCode-Offline](https://github.com/Haitham8888/ClaudeCode-Offline) (private)

Binary files (`windows/claude.exe` and `linux/claude`) are excluded from git due to size (242 MB / 247 MB). Copy them manually after pulling the repository.
