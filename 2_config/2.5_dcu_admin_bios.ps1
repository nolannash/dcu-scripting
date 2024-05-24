#needs testing to see if it works

#will need to ensure security on this or similar scripts 100% --> this is something I am not 100% sure about

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