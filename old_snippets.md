--> taken from automated scan file

<!-- # $dcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
 $weeklyLogsFolder = "C:\WeeklyLogs"  # Change the path to your preferred location

 Check if DCU CLI is installed
 if (Test-Path -Path $dcuCliPath -PathType Leaf) {
      Check if the script is running with elevated privileges
     $elevated = ([Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"
    
     if (-not $elevated) {
         # Restart the script with elevated privileges
         Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
         Exit
     }

      Run DCU scan and capture results
     Start-Process $dcuCliPath -ArgumentList "/scan -updateType=bios,firmware,driver,application -outputLog=" -Wait -RedirectStandardOutput "$($env:TEMP)\dcu_output.txt"

      Read the content of the output log file
     $outputLogPath = "$($env:TEMP)\dcu_output.txt"
     $content = Get-Content -Path $outputLogPath

      Create WeeklyLogs folder if it doesn't exist
     if (-not (Test-Path -Path $weeklyLogsFolder -PathType Container)) {
         New-Item -ItemType Directory -Path $weeklyLogsFolder -Force
     }

     Export content to a text file with a dynamic name
     $weeklyLogsFileName = "scan_$(Get-Date -Format 'yyyy-MM-dd').txt"
     $weeklyLogsFilePath = Join-Path $weeklyLogsFolder $weeklyLogsFileName

      Prepare content for the text file
     foreach ($type in "bios", "firmware", "driver", "application") {
         if ($content -match "$type.*Pending.*:\s*(\d+)") {
            $updatesCount = $matches[1]
             Add-Content -Path $weeklyLogsFilePath -Value "$type has updates ready. Count: $updatesCount"
        }
    }

     Write-Host "DCU scan results exported to $weeklyLogsFilePath."
 }
 else {
     Write-Host "DCU CLI not found. Please check if Dell Command Update is installed."
 }

  Keep the PowerShell window open
 Read-Host "Press Enter to exit..." -->

--> taken from clean and install script
<!-- $WingetCommand = Get-Command -Name winget.exe -ErrorAction SilentlyContinue

if ($WingetCommand) {
    Write-Host "winget.exe found. Proceeding with Dell Command Update operations..." -ForegroundColor Green

    # Check if Dell Command Update is installed
    $DcuInstalled = Test-Path -Path "C:\Program Files\Dell\CommandUpdate"

    if ($DcuInstalled) {
        Write-Host "Dell Command Update found. Uninstalling and installing the latest version..." -ForegroundColor Green
        
        # Uninstall Dell Command Update
        Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList '/uninstall' -Wait -WindowStyle hidden
        
        # Install the latest version using winget
        Start-Process $WingetCommand.Path -ArgumentList 'install --name Dell.CommandUpdate.Universal --force' -Wait -WindowStyle hidden
    } else {
        Write-Host "Dell Command Update not found. Installing the latest version..." -ForegroundColor Yellow
        
        # Install the latest version using winget
        Start-Process $WingetCommand.Path -ArgumentList 'install --name Dell.CommandUpdate.Universal --force' -Wait -WindowStyle hidden
    }

    Write-Host "Dell Command Update removal and installation completed." -ForegroundColor Green

    #set ninja custom field value
    Ninja-Property-Set dcu_installed 'true'

    $now = Get-Date
    $formattedDateTime = $now.ToString("dd/MM/yyyy [HH:mm:ss]") 
    Ninja-Property-Set last_dcu_install "$formattedDateTime"


} else {
    Write-Host "winget.exe not found. Please ensure that it is installed and included in the system PATH." -ForegroundColor Red
    
}
Pause -->

--> taken from config script
 <!-- Registry path might need verification
reg add HKLM\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG\ /v ShowSetupPopup /t REG_DWORD /d 0 /f
reg add HKLM\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG\ /v DCUconfigured /t REG_DWORD /d 1 /f

 DCU CLI configuration (assuming it is already installed)
$dcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"

#the configuration is one of the largest parts that needs clarification --> are we exporting? doing it per client? what is the policy on this 

<!-- if (Test-Path -Path $dcuCliPath -PathType Leaf) {
    Start-Process $dcuCliPath -Argumentlist '/configure -updatesNotification=Disable' -WindowStyle hidden -Wait
    # Start-Process $dcuCliPath -Argumentlist '/configure -scheduleAction=DownloadInstallAndNotify' -WindowStyle hidden -Wait
    Start-Process $dcuCliPath -Argumentlist '/configure -reboot=disable' -WindowStyle hidden -Wait
    # Start-Process $dcuCliPath -Argumentlist '/configure -scheduleWeekly=Tue,13:45' -WindowStyle hidden -Wait
    Start-Process $dcuCliPath -Argumentlist '/configure -updatesNotification=Disable' -WindowStyle hidden -Wait
    Start-Process $dcuCliPath -Argumentlist '/configure -userConsent=disable' -WindowStyle hidden -Wait
    Start-Process $dcuCliPath -Argumentlist '/configure -autoSuspendBitLocker=enable' -WindowStyle hidden -Wait

    Write-Host "Dell Command Update has been configured." -ForegroundColor Green
} else {
    Write-Host "DCU CLI not found. Please check if Dell Command Update is installed." -ForegroundColor Red
} --> 
