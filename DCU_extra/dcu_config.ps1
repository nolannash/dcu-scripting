# DCU CLI configuration (assuming it is already installed)
reg add HKLM\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG\ /v ShowSetupPopup /t REG_DWORD /d 0 /f
reg add HKLM\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG\ /v DCUconfigured /t REG_DWORD /d 1 /f

$dcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"


if (Test-Path -Path $dcuCliPath -PathType Leaf) {
    Start-Process $dcuCliPath -Argumentlist '/configure -updatesNotification=disable' -WindowStyle hidden -Wait
    Start-Process $dcuCliPath -Argumentlist '/configure -reboot=disable' -WindowStyle hidden -Wait
    Start-Process $dcuCliPath -Argumentlist '/configure -userConsent=disable' -WindowStyle hidden -Wait
    Start-Process $dcuCliPath -Argumentlist '/configure -autoSuspendBitLocker=enable' -WindowStyle hidden -Wait
    }
    Write-Host "Dell Command Update has been configured"
    else {
    Write-Host "DCU CLI not found. Please check if Dell Command Update is installed."
}
