param (
    [string]$UpdateType = "all"
)

# Specify the path to dcu-cli.exe
$DcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"

# Check if dcu-cli.exe exists
if (Test-Path $DcuCliPath -PathType Leaf) {
    # Display a message indicating the detection of Dell Command Update CLI
    Write-Host "Dell Command Update CLI found. Proceeding with operations..." -ForegroundColor Green

    try {
        # Start dcu-cli.exe to check if it runs properly
        Start-Process -FilePath $DcuCliPath -ArgumentList "/version" -Wait -ErrorAction Stop
        # Display a message indicating that Dell Command Update CLI is running properly
        Write-Host "Dell Command Update CLI is running properly." -ForegroundColor Green

        # Run a scan for a specific update type or for all types
        $scanResult = if ($UpdateType -eq "all") {
            Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=bios,firmware,driver " -Wait -PassThru -WindoStyle hidden 
        } else {
            Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=$UpdateType " -Wait -PassThru
        }

        # Update a Ninja custom field based on updates found
        # $ninjaProperty = "dcu_${UpdateType}_updates_installed"
        # Ninja-Property-Set $ninjaProperty ($scanResult.ExitCode -eq 1)

        if ($scanResult.ExitCode -eq 1) {
            # Display a message if updates are found, and Ninja custom field has been set
            Write-Host "Updates found. Ninja custom fields have been set." -ForegroundColor Green

            # Apply updates
            Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -updateType=$UpdateType -reboot=disable -outputlog=C:\Users\$env:username\Desktop\dcuUpdateLog.log" -Wait
            Write-Host "Updates applied successfully." -ForegroundColor Green
        } else {
            # Display a message if no updates are found
            Write-Host "No updates found." -ForegroundColor Green
        }

        # Set custom field "last_dcu_scan" with today's date and time
        $now = Get-Date
        $formattedDateTime = $now.ToString("dd/MM/yyyy [HH:mm:ss]")
        # Ninja-Property-Set last_dcu_scan "$formattedDateTime"
    } catch {
        # Display an error message if an exception occurs during the process
        Write-Host "Error: $_" -ForegroundColor Red
    }
} else {
    # Display an error message if Dell Command Update CLI is not found
    Write-Host "Error: Dell Command Update CLI (dcu-cli.exe) not found at $DcuCliPath." -ForegroundColor Red
}

# Pause to keep the PowerShell window open for manual inspection
Pause
