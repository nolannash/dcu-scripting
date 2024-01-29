# #OutWithTheDellBloat
# # Set-ExecutionPolicy Bypass -scope Process -Force
# # $ErrorActionPreference = “SilentlyContinue”

# $ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
#     if ($ResolveWingetPath){
#            $WingetPath = $ResolveWingetPath[-1].Path
#     }

# $Wingetpath = Split-Path -Path $WingetPath -Parent
# Set-Location $wingetpath

# #Dell Command | Update for Windows Universal¦ 
# .\winget.exe uninstall --accept-source-agreements --name Dell.CommandUpdate.Universal -h



# winget source reset msstore
# Get-AppxPackage DellInc.DellDigitalDelivery | Remove-AppxPackage -Allusers
# Get-AppxPackage Dell.CommandUpdate.Universal | Remove-AppxPackage -AllUsers
# Get-AppxPackage DellInc.DellSupportAssistforPCs | Remove-AppxPackage -AllUsers


# Uninstall-package -name "Dell Command | Update" -allversions -force
# Uninstall-package -name "Dell Digital Delivery" -allversions -force
# Uninstall-package -name "Dell Command | Configure" -allversions -force
# remove-item -path "HKLM:\SOFTWARE\Dell Inc" -Recurse -force
# remove-item -path "HKLM:\SOFTWARE\Dell Computer Corporation" -Recurse -force
# remove-item -path "HKLM:\SOFTWARE\Dell" -Recurse -force
# remove-item -path "HKLM:\SOFTWARE\WOW6432Node\Dell" -Recurse -force
# remove-item -path "HKLM:\SOFTWARE\WOW6432Node\Dell Computer Corporation" -recurse -force

# Invoke-Command -ScriptBlock { Start-Process .\Dell-Command-Update-Windows-Universal-Application_DT6YC_WIN_4.6.0_A00.exe -ArgumentList /s -Wait -NoNewWindow }

# OutWithTheDellBloat
# Set-ExecutionPolicy Bypass -Scope Process -Force
# $ErrorActionPreference = "SilentlyContinue"

# Resolve path to winget.exe
$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
if ($ResolveWingetPath) {
    $WingetPath = $ResolveWingetPath[-1].Path
}

$Wingetpath = Split-Path -Path $WingetPath -Parent
Set-Location $Wingetpath

# Check if Dell Command Update is installed
$DcuInstalled = Get-Command -ErrorAction SilentlyContinue -SourcePath "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ErrorAction SilentlyContinue

if ($DcuInstalled) {
    Write-Host "Dell Command Update found. Uninstalling and installing the latest version..."
    # Uninstall Dell Command Update
    Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList '/uninstall' -Wait -WindowStyle hidden
    
    # Install the latest version using winget
    .\winget.exe install --name Dell.CommandUpdate.Universal --force
} else {
    Write-Host "Dell Command Update not found. Installing the latest version..."
    # Install the latest version using winget
    .\winget.exe install --name Dell.CommandUpdate --force
}
Write-Host "Dell Command Update removal and installation completed."
Pause


### CONFIG BELOW
# reg add HKLM\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG\ /v ShowSetupPopup /t REG_DWORD /d 0 /f
# reg add HKLM\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG\ /v DCUconfigured /t REG_DWORD /d 1 /f
# Set-ItemProperty HKLM:\SOFTWARE\WOW6432Node\ABC -Name "DCU" -Value "Added!!" -Type String -Force


# $Test = Test-Path -Path "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -Pathtype Leaf
# If ($Test -eq 'True'){
# Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -updatesNotification=Disable'-WindowStyle hidden -wait
# # Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -biosPassword="D35kt0p1!"'-WindowStyle hidden -wait
# # Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -scheduleAction=DownloadInstallAndNotify'-WindowStyle hidden -wait
# Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -reboot=disable'-WindowStyle hidden -wait
# Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -scheduleWeekly=Tue,13:45'-WindowStyle hidden -wait
# Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -updatesNotification=Disable'-WindowStyle hidden -Wait
# Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -userConsent=disable'-WindowStyle hidden -wait
# Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -autoSuspendBitLocker=enable'-WindowStyle hidden -wait
# Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -silent -lockSettings=enable'-WindowStyle hidden -wait

# Write-Output "Worked"
# }
# Else {
# Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -updatesNotification=Disable'-WindowStyle hidden -wait
# Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -biosPassword="D35kt0p1!"'-WindowStyle hidden -wait
# Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -scheduleAction=DownloadInstallAndNotify'-WindowStyle hidden -wait
# Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -reboot=disable'-WindowStyle hidden -wait
# Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -scheduleWeekly=Tue,13:45'-WindowStyle hidden -wait
# Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -updatesNotification=Disable'-WindowStyle hidden -wait
# Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -userConsent=disable'-WindowStyle hidden -wait
# Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -autoSuspendBitLocker=enable'-WindowStyle hidden -wait
# Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -Argumentlist '/configure -silent -lockSettings=enable'-WindowStyle hidden -wait
# Write-Output "Worked 86"
# }







#needs testing to see if it works

powershell -NoProfile -NonInteractive -Command "Uninstall-Module DellBiosProvider"  -AllVersions -force

Install-PackageProvider Nuget -Force; 
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module DellBiosProvider -Force
Import-Module DellBIOSProvider
# $BPW = Get-Item -Path "DellSmbios:\Security\IsAdminPasswordSet" | Select-Object -ExpandProperty CurrentValue
If ( $BPW -eq 'False') {
Set-Item -Path DellSmbios:\Security\AdminPassword "DONT MESS WITH THE PASSWORD"
 write-output "Added" }
 Else {
# Set-Item -Path DellSmbios:\Security\AdminPassword "ADD A PASSWORD HERE" -Password "PASSWORD STUFF GOES HERE"

write-output "changed" }
