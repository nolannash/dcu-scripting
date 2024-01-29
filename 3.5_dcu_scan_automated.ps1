#this file might no longer be needed, if possible we could set the above script to run on a set timeframe and ALSO have it be run manually

$dcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"

# Check if DCU CLI is installed
if (Test-Path -Path $dcuCliPath -PathType Leaf) {
    # Define update types
    $updateTypes = @("bios", "firmware", "driver","application")

    foreach ($type in $updateTypes) {
        # Run DCU scan for the specific update type
        $output = Start-Process $dcuCliPath -ArgumentList "/scan -updateType=$type -outputLog=" -Wait -NoNewWindow -RedirectStandardOutput "$($env:TEMP)\dcu_output.txt" -PassThru

        # Read the content of the output log file
        $content = Get-Content -Path "$($env:TEMP)\dcu_output.txt"

        # Check if there are pending updates for the specific type
        $updatesFound = $content -match 'Pending.*:\s*(\d+)'

        # Print scanning message
        Write-Host "Scanning for $type updates..." -NoNewline

        # Print results in the terminal
        if ($updatesFound) {
            $updatesCount = $matches[1]
            Write-Host " found. Count: $updatesCount" -ForegroundColor Green
        } else {
            Write-Host " not found." -ForegroundColor Red
        }
    }
}
else {
    Write-Host "DCU CLI not found. Please check if Dell Command Update is installed." -ForegroundColor Red
}

# Keep the PowerShell window open
Read-Host "Press Enter to exit..."

