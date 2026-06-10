#!/bin/bash
# Claude Code - Offline Installation (Linux/RHEL)
set -e

echo "============================================"
echo " Claude Code - Offline Installation (Linux)"
echo " Version: 2.1.170"
echo "============================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Step 1: Check prerequisites
echo "[1/4] Checking prerequisites..."

# Check for Git
if command -v git &>/dev/null; then
    echo "[✅] Git found: $(git --version)"
else
    echo "[❌] Git is required. Install it:"
    echo "     sudo dnf install git   (RHEL/Fedora)"
    echo "     sudo apt install git   (Debian/Ubuntu)"
    exit 1
fi

# Check for curl
if ! command -v curl &>/dev/null; then
    echo "[❌] curl is required. Install it:"
    echo "     sudo dnf install curl"
    exit 1
fi

# Step 2: Install binary
echo ""
echo "[2/4] Installing Claude Code binary..."

BINARY="$SCRIPT_DIR/claude"
if [ ! -f "$BINARY" ]; then
    echo "[ERROR] claude binary not found in $SCRIPT_DIR"
    exit 1
fi

# Install to ~/.local/bin
mkdir -p "$HOME/.local/bin"
cp "$BINARY" "$HOME/.local/bin/claude"
chmod +x "$HOME/.local/bin/claude"
echo "[✅] Binary installed to: $HOME/.local/bin/claude"

# Add to PATH if not already
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "[ℹ] Adding ~/.local/bin to PATH..."

    # Detect shell
    if [ -n "$BASH_VERSION" ]; then
        RC_FILE="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        RC_FILE="$HOME/.zshrc"
    else
        RC_FILE="$HOME/.bashrc"
    fi

    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC_FILE"
    echo "[✅] Added to PATH in $RC_FILE"
    echo "     Run: source $RC_FILE   (or open new terminal)"
fi

# Step 3: Install Claude Code launcher
echo ""
echo "[3/4] Setting up Claude Code launcher..."
cd "$HOME/.local/bin"
./claude install 2>/dev/null || true
echo "[✅] Claude Code launcher setup complete"

# Step 4: Copy configuration
echo ""
echo "[4/4] Copying configuration files..."
mkdir -p "$HOME/.claude"
if [ -f "$SCRIPT_DIR/../config/settings.json" ]; then
    cp "$SCRIPT_DIR/../config/settings.json" "$HOME/.claude/settings.json"
    echo "[✅] Configuration file installed to: $HOME/.claude/settings.json"
else
    echo "[⚠] settings.json not found, creating default..."
    cat > "$HOME/.claude/settings.json" << 'EOF'
{
  "permissions": { "allow": [ "Bash(*)", "Read(*)", "Write(*)", "Edit(*)" ] },
  "env": {
    "ANTHROPIC_BASE_URL": "http://TBD:30000",
    "ANTHROPIC_API_KEY": "sk-offline",
    "ANTHROPIC_AUTH_TOKEN": "sk-offline",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "DISABLE_AUTOUPDATER": "1",
    "DISABLE_TELEMETRY": "1",
    "DO_NOT_TRACK": "1",
    "CLAUDE_CODE_DISABLE_OFFICIAL_MARKETPLACE_AUTOINSTALL": "1",
    "CLAUDE_CODE_DISABLE_BACKGROUND_TASKS": "1",
    "DISABLE_LOGIN_COMMAND": "1",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "DeepSeek-V4-Flash",
    "CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY": "1"
  },
  "fallbackModel": [
    "DeepSeek-V4-Flash"
  ]
}
EOF
    echo "[✅] Default configuration created"
fi

# Verify
echo ""
echo "----- Verification -----"
if [ -f "$HOME/.local/bin/claude" ]; then
    echo "[✅] Claude Code installed successfully!"
    echo "    Binary: $HOME/.local/bin/claude"
else
    echo "[ERROR] Installation failed"
    exit 1
fi

echo ""
echo "============================================"
echo "  Installation Complete!"
echo "============================================"
echo ""
echo "  NEXT STEPS:"
echo "  1. Update your SGLang server IP in:"
echo "     ~/.claude/settings.json"
echo ""
echo "  2. Run the environment setup:"
echo "     source scripts/setup-env-linux.sh"
echo ""
echo "  3. Or manually export variables:"
echo "     export ANTHROPIC_BASE_URL=http://TBD:30000"
echo "     export ANTHROPIC_API_KEY=sk-offline"
echo "     export ANTHROPIC_DEFAULT_HAIKU_MODEL=DeepSeek-V4-Flash"
echo "     export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1"
echo ""
echo "  4. Launch Claude Code:"
echo "     claude --model DeepSeek-V4-Flash --bare"
echo ""
echo "  5. OPTIONAL - Install browser error review tool:"
echo "     git clone https://github.com/tollebrandon/agent-browse"
echo "     cd agent-browse"
echo "     npm install && npm run build"
echo '     claude mcp add --transport stdio agent-browse -- node "$(pwd)/agent-browse/dist/index.js"'
echo ""
echo "  NOTE: Update the IP address to match"
echo "        your SGLang server address."
echo ""
