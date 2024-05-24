# Specify possible paths where dcu-cli.exe might be located
$PossibleDcuCliPaths = @(
    "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe",
    "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
)

# Initialize a variable to store the actual path of dcu-cli.exe
$DcuCliPath = $null
$logStorage = Ninja-Property-Get dcuLogLocation
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
        Start-Process -FilePath $DcuCliPath -ArgumentList "/version" -Wait -NoNewWindow -ErrorAction Stop
        # Display a message indicating that Dell Command Update CLI is running properly
        Write-Host "`nDell Command Update CLI is running properly." 

        $now = Get-Date
        $formattedDateTime = $now.ToString("MM/dd/yyyy [HH:mm:ss]")
        Ninja-Property-Set mostRecentDcuScan $formattedDateTime --stdin

        # Specify the path to save the log file (use date as a unique ID)
        $LogFilePath = "$logStorage\$($now.ToString('MM-dd-yyyy_hh-mm'))_dcuUpdateLog.log"

        # Save the output of the scan to the specified log file
        Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=bios,firmware,driver,application " -NoNewWindow -RedirectStandardOutput $LogFilePath -Wait -ErrorAction Stop 
        # Display a message indicating the log file is saved
        Write-Host "Scan completed Successfully"
        Write-Host "Log file saved to $LogFilePath" 

        # Read the contents of the log file
        $logContent = Get-Content -Path $LogFilePath

        # Filter lines starting with "Number of Applicable Updates"
        $applicableUpdatesLine = $logContent | Where-Object { $_ -match '^Number of Applicable Updates' }

        # Set Ninja custom field with the applicable updates line
        Ninja-Property-Set dcuScanLog $applicableUpdatesLine --stdin
    } catch {
        # Display an error message if an exception occurs during the process
        Write-Host "Error: $_" -
    }
} else {
    # Display an error message if Dell Command Update CLI is not found
    Write-Host "Error: Dell Command Update CLI (dcu-cli.exe) not found in the expected paths." 
}
