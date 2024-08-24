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
    Write-Host "Dell Command Update CLI found at $DcuCliPath. Proceeding with operations..."

    try {
        # Start dcu-cli.exe to check if it runs properly
        $DcuCliVersionResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/version" -Wait -NoNewWindow -PassThru
        if ($DcuCliVersionResult.ExitCode -eq 0) {
            Write-Host "`nDell Command Update CLI is running properly."

            # Get the current date and time
            $now = Get-Date
            $formattedDateTime = $now.ToString("yyyy-MM-dd_HH-mm-ss")

            # Hardcode an export directory path for logs
            $ExportDir = "#### ADD YOUR PATH ####"  # Replace this with your desired export directory path

            # Check if the export directory exists, if not create it
            if (-not (Test-Path -Path $ExportDir)) {
                New-Item -Path $ExportDir -ItemType Directory | Out-Null
            }

            # Define the path where the update log will be exported
            $ExportPath = Join-Path $ExportDir "update_log_$formattedDateTime.txt"

            # Define a flag to track whether a reboot is needed
            $rebootNeeded = $false
            $outputLog = ""

            # Check for all updates
            Write-Host "Scanning for updates..."
            $ScanResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/scan" -NoNewWindow -PassThru -Wait -ErrorAction Stop
            $outputLog += "Scan operation completed with Exit Code: $($ScanResult.ExitCode)`n"

            # Check exit code for the successful scan operation
            switch ($ScanResult.ExitCode) {
                0 {
                    Write-Host "Scan operation completed successfully."
                }
                500 {
                    Write-Host "No updates were found for the system. The system is up to date."
                    $outputLog += "No updates found for the system as of - $formattedDateTime`n"
                    $outputLog | Out-File -FilePath $ExportPath -Encoding UTF8
                    Exit
                }
                default {
                    Write-Host "Error: Failed to perform scan operation. Exit code: $($ScanResult.ExitCode)"
                    $outputLog += "Error: Failed to perform scan operation. Exit code: $($ScanResult.ExitCode)`n"
                    $outputLog | Out-File -FilePath $ExportPath -Encoding UTF8
                    Exit
                }
            }

            # Apply updates with reboot enabled
            Write-Host "Applying updates..."
            $ApplyUpdatesResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -reboot=enable -autoSuspendBitlocker=enable" -NoNewWindow -PassThru -Wait -ErrorAction Stop
            $outputLog += "Apply updates operation completed with Exit Code: $($ApplyUpdatesResult.ExitCode)`n"

            # Check exit code for successful update application
            switch ($ApplyUpdatesResult.ExitCode) {
                0 {
                    Write-Host "Updates applied successfully. No reboot needed."
                    $outputLog += "Updates applied successfully as of - $formattedDateTime. No reboot needed.`n"
                }
                1 {
                    Write-Host "Updates applied successfully. Reboot is needed. Rebooting system..."
                    $outputLog += "Updates applied successfully as of - $formattedDateTime. Reboot is needed.`n"
                    $outputLog | Out-File -FilePath $ExportPath -Encoding UTF8
                    Restart-Computer -Force
                }
                5 {
                    Write-Host "Updates applied successfully. Reboot is needed. Rebooting system..."
                    $outputLog += "Updates applied successfully as of - $formattedDateTime. Reboot is needed.`n"
                    $outputLog | Out-File -FilePath $ExportPath -Encoding UTF8
                    Restart-Computer -Force
                }
                1001 {
                    Write-Host "Error: The apply updates operation was canceled."
                    $outputLog += "Error: The apply updates operation was canceled.`n"
                }
                1002 {
                    Write-Host "Error: An error occurred while downloading a file during the apply updates operation. Check your network connection and retry the command."
                    $outputLog += "Error: An error occurred while downloading a file during the apply updates operation. Check your network connection and retry the command.`n"
                }
                default {
                    Write-Host "Error: Failed to apply updates. Exit code: $($ApplyUpdatesResult.ExitCode)"
                    $outputLog += "Error: Failed to apply updates. Exit code: $($ApplyUpdatesResult.ExitCode)`n"
                }
            }

            # Export log file
            $outputLog | Out-File -FilePath $ExportPath -Encoding UTF8
        } else {
            Write-Host "Error: Dell Command Update CLI failed to run properly."
        }
    } catch {
        # Display an error message if an exception occurs during the process
        Write-Host "Error: $_"
    }

} else {
    # Display an error message if Dell Command Update CLI is not found
    Write-Host "Error: Dell Command Update CLI (dcu-cli.exe) not found in the expected paths."
}
