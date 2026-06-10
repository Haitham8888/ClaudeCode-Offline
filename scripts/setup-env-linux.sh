#!/bin/bash
# Claude Code - Offline Environment Setup (Linux Bash)
# قم بتعديل IP والمنفذ حسب إعدادات سيرفر SGLang الخاص بك

export ANTHROPIC_BASE_URL="http://TBD:30000"
export ANTHROPIC_API_KEY="sk-offline"
export ANTHROPIC_AUTH_TOKEN="sk-offline"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"
export DISABLE_AUTOUPDATER="1"
export DISABLE_TELEMETRY="1"
export DO_NOT_TRACK="1"
export CLAUDE_CODE_DISABLE_OFFICIAL_MARKETPLACE_AUTOINSTALL="1"
export CLAUDE_CODE_DISABLE_BACKGROUND_TASKS="1"
export DISABLE_LOGIN_COMMAND="1"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="DeepSeek-V4-Flash"
export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="1"
export MAX_THINKING_TOKENS="0"
export CLAUDE_CODE_SIMPLE="1"

echo -e "\n✅ Claude Code Offline Environment Configured!"
echo "   SGLang Server: $ANTHROPIC_BASE_URL"
echo ""
echo "Now run: claude --model DeepSeek-V4-Flash --bare"
echo ""
