param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

& "$PSScriptRoot\start_mock_api.ps1"

Write-Host 'Starting Flutter...'
& flutter run @FlutterArgs
