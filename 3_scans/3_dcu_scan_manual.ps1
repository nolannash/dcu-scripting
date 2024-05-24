# Specify the path to dcu-cli.exe
$DcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"

# Check if dcu-cli.exe exists
if (Test-Path $DcuCliPath -PathType Leaf) {
    # Display a message indicating the detection of Dell Command Update CLI
    Write-Host "Dell Command Update CLI found. Proceeding with operations..." -ForegroundColor Green

    try {
        # Start dcu-cli.exe to check if it runs properly
        Start-Process -FilePath $DcuCliPath -ArgumentList "/version" -Wait -NoNewWindow -ErrorAction Stop
        # Display a message indicating that Dell Command Update CLI is running properly
        Write-Host "`nDell Command Update CLI is running properly." -ForegroundColor Green
        # Set Ninja custom field "last_dcu_scan" with today's date and time
        $now = Get-Date
        $formattedDateTime = $now.ToString("dd/MM/yyyy [HH:mm:ss]")
        # Ninja-Property-Set last_dcu_scan "$formattedDateTime"

        # Specify the path to save the log file (use date as unique ID)
        $LogFilePath = "C:\weeklyLogs\$($now.ToString('dd-MM-yyyy_hh-mm'))_dcuUpdateLog.log"

        # Save the output of the scan to the specified log file
        Start-Process -FilePath $DcuCliPath -ArgumentList "/scan -updateType=bios,firmware,driver,application" -NoNewWindow -RedirectStandardOutput $LogFilePath -Wait -ErrorAction Stop 
        # Display a message indicating the log file is saved
        Write-Host "Scan completed Successfully" -ForegroundColor Cyan
        Write-Host "Log file saved to $LogFilePath" -ForegroundColor Green
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


# $WingetCommand = Get-Command -Name winget.exe -ErrorAction SilentlyContinue

# if ($WingetCommand) {
#     Write-Host "winget.exe found. Proceeding with Dell Command Update operations..." -ForegroundColor Green

#     try {
#         # Check if Dell Command Update is already installed
#         $DcuInstalled = Test-Path -Path "C:\Program Files\Dell\CommandUpdate"

#         if ($DcuInstalled) {
#             Write-Host "Dell Command Update found. Uninstalling and installing the latest version..." -ForegroundColor Green
        
#             # Uninstall Dell Command Update
#             Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList '/uninstall' -Wait -WindowStyle hidden
        
#             # Install to most stable version available using winget, will auto update itself if needed
#             Start-Process $WingetCommand.Path -ArgumentList 'install --name Dell.CommandUpdate.Universal --force' -Wait -WindowStyle hidden
#         } else {
#             Write-Host "Dell Command Update not found. Installing the latest version..." -ForegroundColor Yellow
        
#             # Install the latest version using winget
#             Start-Process $WingetCommand.Path -ArgumentList 'install --name Dell.CommandUpdate.Universal --force' -Wait -WindowStyle hidden
#         }

#         Write-Host "Dell Command Update removal and installation completed." -ForegroundColor Green

#         # Set Ninja custom field values for successful installation
#         Ninja-Property-Set set dellcommandupdateInstalled true

#         # Get the current date and time and format it
#         $now = Get-Date
#         $formattedDateTime = $now.ToString("dd/MM/yyyy [HH:mm:ss]") 

#         # Set Ninja custom field with the installation timestamp
#         # Ninja-Property-Set last_dcu_install "$formattedDateTime"
#     }
#     catch {
#         # Handle errors during installation
#         Write-Host "Error: $_" -ForegroundColor Red

#         # Set Ninja custom field values on error
#         Ninja-Property-Set set dellcommandupdateInstalled 'false'
#         # Ninja-Property-Set last_dcu_install "Installation failed"
#     }
# } else {
#     Write-Host "winget.exe not found. Please ensure that it is installed and included in the system PATH." -ForegroundColor Red
# }