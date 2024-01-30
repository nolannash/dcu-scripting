$dcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
if (Test-Path $dcuCliPath -PathType Leaf) {
    Write-Host "Dell Command Update CLI found. Scanning for firmware update..." -ForegroundColor Green

    # Run an firmware update scan
    $scanResult = Start-Process -FilePath $dcuCliPath -ArgumentList '/scan -updateType=firmware ' -Wait -NoNewWindow -PassThru

    if ($scanResult.ExitCode -ne 0) {
        if ($scanResult.ExitCode -eq 500) {
            Write-Host "`nNo firmware update found." -ForegroundColor Yellow
        } else {
            Write-Host "`nPossible firmware update found. Attempting to apply update..." -ForegroundColor Green

            $now = Get-Date
            $formattedDateTime = $now.ToString("dd/MM/yyyy [HH:mm:ss]")
            # Ninja-Property-Set last_firmware_scan "$formattedDateTime"

            # Specify the path to save the log file (use date as a unique ID)
            $LogFilePath = "C:\weeklyLogs\$($now.ToString('dd-MM-yyyy_hh-mm'))_DCU_firmware_Log.log"

            # Apply firmware update without reboot
            $applyResult = Start-Process -FilePath $dcuCliPath -ArgumentList "/applyUpdates -updateType=firmware -reboot=disable " -Wait -RedirectStandardOutput $LogFilePath -PassThru

            # Check if a reboot is needed (exit code 5)
            if ($applyResult.ExitCode -eq 5) {
                Write-Host "`nA reboot is needed to confirm updates. Please reboot the system." -ForegroundColor Red
            } elseif ($applyResult.ExitCode -eq 1) {
                Write-Host "`nA reboot is required from the execution of an operation. Reboot the system to complete the operation." -ForegroundColor Red
            } elseif ($applyResult.ExitCode -eq 0) {
                Write-Host "firmware update applied successfully." -ForegroundColor Green
            } else {
                Write-Host "Error applying firmware update. Check the log file for details: $LogFilePath" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "`nError during firmware update scan. Check the log file for details." -ForegroundColor Red
    }
} else {
    Write-Host "Error: Dell Command Update CLI (dcu-cli.exe) not found at $dcuCliPath." -ForegroundColor Red
}
