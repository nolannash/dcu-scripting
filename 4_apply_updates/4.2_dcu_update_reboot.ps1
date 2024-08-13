
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
        Write-Output "`nDell Command Update CLI is running properly."

        $now = Get-Date
        $formattedDateTime = $now.ToString("MM/dd/yyyy [HH:mm:ss]")

        # Check for all updates
        $ScanResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/scan" -NoNewWindow -PassThru -Wait -ErrorAction Stop

        # Check exit code for successful scan operation
        if ($ScanResult.ExitCode -eq 0) {
            Write-Output "Scan: Successful"
        } elseif ($ScanResult.ExitCode -eq 500) {
            Write-Output "No updates were found for the system. The system is up to date or no updates were found for the provided filters."
            Write-Output "Modify the filters and rerun the commands."
            Ninja-Property-Set dcuScanLog "No updates found for the system as of - $formattedDateTime"
            Ninja-Property-Set mostRecentDcuScan "No updates found - $formattedDateTime" --stdin
            Ninja-Property-Set dcuRebootStatus "No Reboot needed. All applicable updates applied successfully"
            Exit
        } else {
            Write-Output "Error: Failed to perform scan operation. Exit code: $($ScanResult.ExitCode)"
            Exit
        }

        # Apply updates
        $ApplyUpdatesResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -reboot=enable -autoSuspendBitlocker=enable" -NoNewWindow -PassThru -Wait -ErrorAction Stop

        # Check exit code for successful update application
        if ($ApplyUpdatesResult.ExitCode -eq 0) {
            # Set Ninja custom fields
            Ninja-Property-Set dcuScanLog "Updates applied successfully as of - $formattedDateTime"
            Ninja-Property-Set mostRecentDcuScan $formattedDateTime --stdin
            Ninja-Property-Set dcuRebootStatus "No reboot needed"
            
            Write-Output "Updates applied successfully. No reboot needed."
        } elseif ($ApplyUpdatesResult.ExitCode -eq 1 -or $ApplyUpdatesResult.ExitCode -eq 5) {
            # Reboot required from the execution of an operation or pending from a previous operation
            Write-Output "A reboot is needed... Rebooting now."
            Ninja-Property-Set dcuRebootStatus "Reboot needed"
            Ninja-Property-Set dcuScanLog "Updated and rebooted successfully as of - $formattedDateTime"
            Write-Output "Updates applied successfully. Reboot is needed. Rebooting system..."
            Write-Output "Rebooting..."
            Restart-Computer -Force
        } elseif ($ApplyUpdatesResult.ExitCode -eq 1001) {
            Write-Output "Error: The apply updates operation was canceled."
        } elseif ($ApplyUpdatesResult.ExitCode -eq 1002) {
            Write-Output "Error: An error occurred while downloading a file during the apply updates operation. Check your network connection and retry the command."
        } else {
            Write-Output "Error: Failed to apply updates. Exit code: $($ApplyUpdatesResult.ExitCode)"
        }
    } catch {
        # Display an error message if an exception occurs during the process
        Write-Output "Error: $_"
    }
} else {
    # Display an error message if Dell Command Update CLI is not found
    Write-Output "Error: Dell Command Update CLI (dcu-cli.exe) not found in the expected paths."
}


