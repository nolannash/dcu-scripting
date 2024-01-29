# Specify the path to dcu-cli.exe
$DcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"

# Check if dcu-cli.exe exists
if (Test-Path $DcuCliPath -PathType Leaf) {
    Write-Host "Dell Command Update CLI found. Proceeding with operations..." -ForegroundColor Green

    try {
        # Start dcu-cli.exe to check if it runs properly
        Start-Process -FilePath $DcuCliPath -ArgumentList "/version" -Wait -ErrorAction Stop
        Write-Host "Dell Command Update CLI is running properly." -ForegroundColor Green

        # Run separate scans for each update type
        $updateTypes = @("bios", "firmware", "driver")
        $updatesFound = $false

        foreach ($type in $updateTypes) {
            $scanResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=$type -autoSuspendBitLocker=enable" -Wait -PassThru
            $updatesFound = $updatesFound -or ($scanResult.ExitCode -eq 1)
        
            # Set Ninja custom field based on updates found
            $ninjaProperty = "dcu_pending_${type}_updates"
            Ninja-Property-Set $ninjaProperty ($scanResult.ExitCode -eq 1)
        }

        if ($updatesFound) {
            Write-Host "Updates found. Ninja custom fields have been set." -ForegroundColor Green
        } else {
            Write-Host "No updates found." -ForegroundColor Green
        }

        # Set Ninja custom field "last_dcu_scan" with today's date and time
        $now = Get-Date
        $formattedDateTime = $now.ToString("dd/MM/yyyy [HH:mm:ss]")
        Ninja-Property-Set last_dcu_scan "$formattedDateTime"

        # Specify the path to save the log file
        $LogFilePath = "C:\weeklyLogs\dcuUpdateLog.log"

        # Save the output of the scan to the specified log file
        Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=bios,firmware,driver -autoSuspendBitLocker=enable" -RedirectStandardOutput $LogFilePath -Wait -ErrorAction Stop

        Write-Host "Log file is saved to $LogFilePath" -ForegroundColor Green
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Error: Dell Command Update CLI (dcu-cli.exe) not found at $DcuCliPath." -ForegroundColor Red
}

Pause
