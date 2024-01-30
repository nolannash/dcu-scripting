# Registry settings to configure Dell Command Update behavior
# Registry path might need verification
reg add HKLM\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG\ /v ShowSetupPopup /t REG_DWORD /d 0 /f
reg add HKLM\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG\ /v DCUconfigured /t REG_DWORD /d 1 /f

# DCU CLI configuration (assuming it is already installed)
$dcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"

# Check if DCU CLI is installed
if (Test-Path -Path $dcuCliPath -PathType Leaf) {

    #these can all be done as a single line but they are separated for now for visibility 

    # Disable update notifications
    Start-Process $dcuCliPath -Argumentlist '/configure -updatesNotification=Disable' -WindowStyle hidden -Wait

    # Disable reboot after updates
    Start-Process $dcuCliPath -Argumentlist '/configure -reboot=disable' -WindowStyle hidden -Wait

    # Enable automatic suspension of BitLocker during updates
    Start-Process $dcuCliPath -Argumentlist '/configure -autoSuspendBitLocker=enable' -WindowStyle hidden -Wait

    # Display a message indicating successful configuration
    Write-Host "Dell Command Update has been configured." -ForegroundColor Green
} else {
    # Display an error message if DCU CLI is not found
    Write-Host "DCU CLI not found. Please check if Dell Command Update is installed." -ForegroundColor Red
}
