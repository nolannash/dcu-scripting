# Registry path might need verification
reg add HKLM\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG\ /v ShowSetupPopup /t REG_DWORD /d 0 /f
reg add HKLM\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG\ /v DCUconfigured /t REG_DWORD /d 1 /f

# DCU CLI configuration (assuming it is already installed)
$dcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"

#the configuration is one of the largest parts that needs clarification --> are we exporting? doing it per client? what is the policy on this 

if (Test-Path -Path $dcuCliPath -PathType Leaf) {
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
}
