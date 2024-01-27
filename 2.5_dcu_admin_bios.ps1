#needs testing to see if it works

powershell -NoProfile -NonInteractive -Command "Uninstall-Module DellBiosProvider"  -AllVersions -force

Install-PackageProvider Nuget -Force; 
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module DellBiosProvider -Force
Import-Module DellBIOSProvider
$BPW = Get-Item -Path "DellSmbios:\Security\IsAdminPasswordSet" | Select-Object -ExpandProperty CurrentValue
If ( $BPW -eq 'False') {
Set-Item -Path DellSmbios:\Security\AdminPassword "D35kt0p1!"
 write-output "Added" }
 Else {
Set-Item -Path DellSmbios:\Security\AdminPassword "D35kt0p1!" -Password "T3chn1c@l"
Set-Item -Path DellSmbios:\Security\AdminPassword "D35kt0p1!" -Password "D35kt0p1"
Set-Item -Path DellSmbios:\Security\AdminPassword "D35kt0p1!" -Password "Technical"
Set-Item -Path DellSmbios:\Security\AdminPassword "D35kt0p1!" -Password "Desktop1!"
Set-Item -Path DellSmbios:\Security\AdminPassword "D35kt0p1!" -Password "D35kt0p1!"
write-output "changed" }