# Specify possible paths where dcu-cli.exe might be located
$PossibleDcuCliPaths = @(
    "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe",
    "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
)

# Initialize a variable to store the actual path of dcu-cli.exe
$DcuCliPath = $null

# Iterate through each possible path to check if dcu-cli.exe exists
foreach ($path in $PossibleDcuCliPaths) {
    if (Test-Path $path -PathType Leaf) {
        # If dcu-cli.exe is found, set the path and break the loop
        $DcuCliPath = $path
        break
    }
}

# Check if dcu-cli.exe was found
if ($DcuCliPath) {
    # Display a message indicating the detection of Dell Command Update CLI
    Write-Output "Dell Command Update CLI found at $DcuCliPath. Proceeding with operations..." 
    try {
        # Start dcu-cli.exe to check if it runs properly
        Start-Process -FilePath $DcuCliPath -ArgumentList "/version" -Wait -NoNewWindow -ErrorAction Stop
        # Display a message indicating that Dell Command Update CLI is running properly
        Write-Output "`nDell Command Update CLI is running properly." -ForegroundColor Green

        $now = Get-Date
        $formattedDateTime = $now.ToString("MM/dd/yyyy [HH:mm:ss]")

        # Define a flag to track whether a reboot is needed
        $rebootNeeded = $false
        $rebootTypes = @()

        # Function to check if exit code indicates a reboot is needed
        function CheckForReboot($exitCode) {
            return ($null -ne $exitCode -and ($exitCode -eq 1 -or $exitCode -eq 5))
        }

        # Check for BIOS updates and apply
        $BiosUpdateResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=bios" -NoNewWindow  -PassThru -Wait -ErrorAction Stop 
        # Attempt to apply updates with reboot disabled
        $BiosApplyResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -updateType=bios -reboot=disable" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
        # Check exit code for reboot indication
        if  (CheckForReboot $BiosApplyResult.ExitCode) {
            $rebootNeeded = $true
            $rebootTypes += "bios"
        }

        # Check for firmware updates and apply
        $FirmwareUpdateResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=firmware" -NoNewWindow  -PassThru -Wait -ErrorAction Stop 
        # Attempt to apply updates with reboot disabled
        $FirmwareApplyResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -updateType=firmware -reboot=disable" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
        # Check exit code for reboot indication
        if (CheckForReboot $FirmwareApplyResult.ExitCode) {
            $rebootNeeded = $true
            $rebootTypes += "firmware"
        }

        # Check for driver updates and apply
        $DriverUpdateResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=driver" -NoNewWindow  -PassThru -Wait -ErrorAction Stop 
        # Attempt to apply updates with reboot disabled
        $DriverApplyResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -updateType=driver -reboot=disable" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
        # Check exit code for reboot indication
        if (CheckForReboot $DriverApplyResult.ExitCode) {
            $rebootNeeded = $true
            $rebootTypes += "drivers"
        }

        # Check for application updates and apply
        $AppUpdateResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=application" -NoNewWindow  -PassThru -Wait -ErrorAction Stop 
        # Attempt to apply updates with reboot disabled
        $AppApplyResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -updateType=application -reboot=disable" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
        # Check exit code for reboot indication
        if (CheckForReboot $AppApplyResult.ExitCode) {
            $rebootNeeded = $true
            $rebootTypes += "application"
        }

        # Set Ninja custom field if a reboot is needed
        if ($rebootNeeded) {
            # Join the reboot types into a comma-separated list
            $rebootTypeList = $rebootTypes -join ", "
            Ninja-Property-Set dcuRebootNeeded "Yes reboot needed, for - $rebootTypeList"
            Ninja-Property-Set mostRecentDcuScan "Updates available as of - $formattedDateTime" --stdin
        } else {
            Ninja-Property-Set dcuRebootNeeded "No reboot needed, updates applied successfully"
            Ninja-Property-Set dcuScanLog "No updates as of - $formattedDateTime"
            Ninja-Property-Set mostRecentDcuScan "Updates Applied - $formattedDateTime" --stdin
        }

        Write-Output "Scans and updates completed successfully." -ForegroundColor Cyan
    } catch {
        # Display an error message if an exception occurs during the process
        Write-Output "Error: $_" -ForegroundColor Red
    }
} else {
    # Display an error message if Dell Command Update CLI is not found
    Write-Output "Error: Dell Command Update CLI (dcu-cli.exe) not found in the expected paths." 
}
