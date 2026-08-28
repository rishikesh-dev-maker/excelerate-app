$mobileRoot = $PSScriptRoot
$projectRoot = Split-Path -Parent $mobileRoot
$mockApiRoot = Join-Path $projectRoot 'mock-api'
$apiUrl = 'http://localhost:3000/programs'

try {
    Invoke-WebRequest -Uri $apiUrl -UseBasicParsing -TimeoutSec 1 | Out-Null
    Write-Host 'Excelerate mock API is already running.'
    exit 0
} catch {
    # The API is not running yet, so start json-server below.
}

Write-Host 'Starting the Excelerate mock API on port 3000...'
Start-Process -FilePath 'npm.cmd' -ArgumentList 'start' -WorkingDirectory $mockApiRoot -WindowStyle Hidden

for ($attempt = 1; $attempt -le 15; $attempt++) {
    Start-Sleep -Seconds 1
    try {
        Invoke-WebRequest -Uri $apiUrl -UseBasicParsing -TimeoutSec 1 | Out-Null
        Write-Host 'Excelerate mock API is ready.'
        exit 0
    } catch {
        # Wait for json-server to finish starting.
    }
}

throw 'The mock API did not start. Run "cd mock-api; npm start" to view its error output.'
