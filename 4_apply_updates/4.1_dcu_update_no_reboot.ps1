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

        # Get the current date and time
        $now = Get-Date
        $formattedDateTime = $now.ToString("yyyy-MM-dd_HH-mm-ss")

        # Optionally hardcode an export directory path
        $ExportDir = "#### ADD YOUR PATH ####"  # Replace this with your desired export directory path

        # Check if the export directory exists, if not create it
        if (-not (Test-Path -Path $ExportDir)) {
            New-Item -Path $ExportDir -ItemType Directory | Out-Null
        }

        # Define the path where the update output will be exported
        $ExportPath = Join-Path $ExportDir "update_log_$formattedDateTime.txt"

        # Define a flag to track whether a reboot is needed
        $rebootNeeded = $false
        $rebootTypes = @()

        # Function to check if exit code indicates a reboot is needed
        function CheckForReboot($exitCode) {
            return ($null -ne $exitCode -and ($exitCode -eq 1 -or $exitCode -eq 5))
        }

        # Apply all updates with reboot disabled
        $updateTypes = @("bios", "firmware", "driver", "application")

        # Initialize a variable to store all output messages
        $outputLog = ""

        foreach ($updateType in $updateTypes) {
            # Check for updates of the current type and log output
            $UpdateResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=$updateType" -NoNewWindow -PassThru -Wait -ErrorAction Stop
            $outputLog += "Scan result for $updateType :`n$($UpdateResult | Format-List | Out-String)`n"
            
            # Apply updates with reboot disabled and log output
            $ApplyResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -updateType=$updateType -reboot=disable" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
            $outputLog += "Apply result for $updateType :`n$($ApplyResult | Format-List | Out-String)`n"

            # Check exit code for reboot indication
            if (CheckForReboot $ApplyResult.ExitCode) {
                $rebootNeeded = $true
                $rebootTypes += $updateType
            }
        }

        # Provide feedback based on whether a reboot is needed and log the output
        if ($rebootNeeded) {
            # Join the reboot types into a comma-separated list
            $rebootTypeList = $rebootTypes -join ", "
            $finalMessage = "Reboot needed for updates: $rebootTypeList. Please reboot your system."
        } else {
            $finalMessage = "Updates applied successfully. No reboot needed."
        }

        Write-Output $finalMessage
        $outputLog += "$finalMessage`n"

        # Export the output log to the specified file
        $outputLog | Out-File -FilePath $ExportPath -Encoding UTF8

        Write-Output "Update log exported to: $ExportPath"
    } catch {
        # Display an error message if an exception occurs during the process
        Write-Output "Error: $_" -ForegroundColor Red
    }
} else {
    # Display an error message if Dell Command Update CLI is not found
    Write-Output "Error: Dell Command Update CLI (dcu-cli.exe) not found in the expected paths." 
}
