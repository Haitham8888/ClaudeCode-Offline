# Claude Code - Offline Environment Setup (Windows PowerShell)
# قم بتعديل IP والمنفذ حسب إعدادات سيرفر SGLang الخاص بك

$env:ANTHROPIC_BASE_URL = "http://TBD:30000"
$env:ANTHROPIC_API_KEY = "sk-offline"
$env:ANTHROPIC_AUTH_TOKEN = "sk-offline"
$env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
$env:DISABLE_AUTOUPDATER = "1"
$env:DISABLE_TELEMETRY = "1"
$env:DO_NOT_TRACK = "1"
$env:CLAUDE_CODE_DISABLE_OFFICIAL_MARKETPLACE_AUTOINSTALL = "1"
$env:CLAUDE_CODE_DISABLE_BACKGROUND_TASKS = "1"
$env:DISABLE_LOGIN_COMMAND = "1"
$env:CLAUDE_CODE_SIMPLE = "1"

Write-Host "`n✅ Claude Code Offline Environment Configured!"
Write-Host "   SGLang Server: $env:ANTHROPIC_BASE_URL"
Write-Host ""
Write-Host "Now run: claude --model DeepSeek-V4-Flash --bare"
Write-Host ""
