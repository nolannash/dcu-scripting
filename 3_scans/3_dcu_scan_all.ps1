# # Specify possible paths where dcu-cli.exe might be located
# $PossibleDcuCliPaths = @(
#     "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe",
#     "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
# )

# # Initialize a variable to store the actual path of dcu-cli.exe
# $DcuCliPath = $null
# $logStorage = Ninja-Property-Get dcuLogLocation
# # Iterate through each possible path to check if dcu-cli.exe exists
# foreach ($path in $PossibleDcuCliPaths) {
#     if (Test-Path $path -PathType Leaf) {
#         # If dcu-cli.exe is found, set the path and break the loop
#         $DcuCliPath = $path
#         break
#     }
# }

# # Check if dcu-cli.exe was found
# if ($DcuCliPath) {
#     # Display a message indicating the detection of Dell Command Update CLI
#     Write-Output "Dell Command Update CLI found at $DcuCliPath. Proceeding with operations..." 

#     try {
#         # Start dcu-cli.exe to check if it runs properly
#         Start-Process -FilePath $DcuCliPath -ArgumentList "/version" -Wait -NoNewWindow -ErrorAction Stop
#         # Display a message indicating that Dell Command Update CLI is running properly
#         Write-Output "`nDell Command Update found and CLI is running properly." 

#         $now = Get-Date
#         $formattedDateTime = $now.ToString("MM/dd/yyyy [HH:mm]")
#         Ninja-Property-Set mostRecentDcuScan $formattedDateTime --stdin

#         # Specify the path to save the log file (use date as a unique ID)
#         $LogFilePath = "$logStorage\$($now.ToString('MM-dd-yyyy_hh-mm'))_dcuUpdateLog.log"

#         # Save the output of the scan to the specified log file
#         Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=bios,firmware,driver,application " -NoNewWindow -RedirectStandardOutput $LogFilePath -Wait -ErrorAction Stop 
#         # Display a message indicating the log file is saved
#         Write-Output "Scan completed Successfully"
#         Write-Output "Log file saved to $LogFilePath" 

#         # Read the contents of the log file
#         $logContent = Get-Content -Path $LogFilePath

#         # Filter lines starting with "Number of Applicable Updates"
#         $applicableUpdatesLine = $logContent | Where-Object { $_ -match '^Number of Applicable Updates' }

#         # Set Ninja custom field with the applicable updates line
#         Ninja-Property-Set dcuScanLog $applicableUpdatesLine --stdin
#     } catch {
#         # Display an error message if an exception occurs during the process
#         Write-Output "Error: $_" -
#     }
# } else {
#     # Display an error message if Dell Command Update CLI is not found
#     Write-Output "Error: Dell Command Update CLI (dcu-cli.exe) not found in the expected paths." 
# }
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
    Write-Host "Dell Command Update CLI found at $DcuCliPath. Proceeding with operations..." 

    try {
        # Start dcu-cli.exe to check if it runs properly
        $DcuCliVersionResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/version" -Wait -NoNewWindow -PassThru
        if ($DcuCliVersionResult.ExitCode -eq 0) {
            Write-Host "`nDell Command Update CLI is running properly."

            $now = Get-Date
            $formattedDateTime = $now.ToString("MM/dd/yyyy [HH:mm]")

            # Define a flag to track whether a reboot is needed
            $rebootNeeded = $false
            $rebootTypes = @()

            # Perform update scans
            $updateTypes = @("bios", "firmware", "driver", "application")
            foreach ($updateType in $updateTypes) {
                Write-Host "Checking for $updateType updates..."
                $scanResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=$updateType" -NoNewWindow -PassThru -Wait -ErrorAction Stop
                # $updateResult = Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=$updateType" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
                #confirm scan vs apply update behavior

                # Check for specific exit codes
                switch ($updateResult.ExitCode) {
                    0 {
                        Write-Host "$updateType updates applied successfully."
                    }
                    1 {
                        Write-Host "Reboot required for $updateType updates."
                        $rebootNeeded = $true
                        $rebootTypes += $updateType
                    }
                    2 {
                        Write-Host "Unknown error occurred during $updateType updates."
                    }
                    4 {
                        Write-Host "Administrative privileges are required to apply $updateType updates."
                    }
                    500..503 {
                        Write-Host "Error during scanning for $updateType updates. Exit Code: $($updateResult.ExitCode)"
                    }
                    1000..1002 {
                        Write-Host "Error while applying $updateType updates. Exit Code: $($updateResult.ExitCode)"
                    }
                    default {
                        Write-Host "Unhandled exit code $($updateResult.ExitCode) during $updateType updates."
                    }
                }
            }

            # Set Ninja custom field based on reboot status
            if ($rebootNeeded) {
                $rebootTypeList = $rebootTypes -join ", "
                Ninja-Property-Set dcuRebootNeeded "Yes reboot needed, for - $rebootTypeList"
                Ninja-Property-Set mostRecentDcuScan "Updates available as of - $formattedDateTime" --stdin
            } else {
                Ninja-Property-Set dcuRebootNeeded "No reboot needed, updates applied successfully"
                Ninja-Property-Set dcuScanLog "No updates as of - $formattedDateTime"
                Ninja-Property-Set mostRecentDcuScan "Updates Applied - $formattedDateTime" --stdin
            }

            Write-Host "Scans and updates completed successfully."
        } else {
            Write-Host "Error: Dell Command Update CLI failed to run properly."
        }
    } catch {
        Write-Host "Error: $_"
    }
} else {
    Write-Host "Error: Dell Command Update CLI (dcu-cli.exe) not found in the expected paths."
}
