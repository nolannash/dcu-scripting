# Specify the path to dcu-cli.exe
$DcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"

# Check if dcu-cli.exe exists
if (Test-Path $DcuCliPath -PathType Leaf) {
    Write-Host "Dell Command Update CLI found. Proceeding with operations..." -ForegroundColor Green

    try {
        # Start dcu-cli.exe to check if it runs properly
        Start-Process -FilePath $DcuCliPath -ArgumentList "/version" -Wait -ErrorAction Stop
        Write-Host "Dell Command Update CLI is running properly." -ForegroundColor Green

        # Run a scan using dcu-cli.exe
        Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=bios,firmware,driver -autoSuspendBitLocker=enable" -Wait -ErrorAction Stop
        Write-Host "Scan completed successfully." -ForegroundColor Green

####this is where I am currently stuck 
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
