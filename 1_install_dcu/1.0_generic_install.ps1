# Function to download and install Dell Command Update using the installer from Dell's website
function Install-DellCommandUpdateUsingInstaller {
# URL of the Dell Command Update installer
    $installerUrl = "https://downloads.dell.com/FOLDER11563484M/1/Dell-Command-Update-Windows-Universal-Application_P83K5_WIN_5.3.0_A00.EXE"
# Path where the installer will be downloaded
    $installerPath = "$env:TEMP\DCU_Setup.exe"
    try {
# Download the installer
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -ErrorAction Stop
# Install the application silently
        Start-Process -FilePath $installerPath -ArgumentList '/s' -Wait -NoNewWindow -ErrorAction Stop
# Clean up by removing the installer file
        Remove-Item $installerPath -Force -ErrorAction Stop
        return $true
    } catch {
        Write-Output "Failed to install Dell Command Update: $_"
        return $false
    }
}
# Main script logic
try {
# call the function to install Dell Command Update using the installer from Dell's website
    $installSuccess = Install-DellCommandUpdateUsingInstaller
# Set 'dcuInstallStatus' property based on installation success
    if ($installSuccess) {

        Ninja-Property-Set dcuInstallStatus 'YES: not configured'
        Ninja-Property-Set dellCommandUpdateInstalled 'YES: not configured'
        Write-Output 'Dell Command Update successfully installed'
    } else {
        Ninja-Property-Set dcuInstallStatus 'NO: Install Failed'
        Ninja-Property-Set dellCommandUpdateInstalled 'NO: Install Failed'
    }
} catch {
# Handle any errors during the installation process
    Write-Output "Error during installation process: $_"
# Set custom fields  on error
    Ninja-Property-Set dcuInstallStatus "NO: $_"
    Ninja-Property-Set dellCommandUpdateInstalled "NO: $_"
}
