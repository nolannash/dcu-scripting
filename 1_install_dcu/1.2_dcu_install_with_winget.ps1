$WingetPath = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_1.22.11261.0_x64__8wekyb3d8bbwe\winget.exe"
# Function to uninstall Dell Command Update using winget
function Uninstall-DellCommandUpdateUsingWinget {
    Write-Output "Uninstalling Dell Command Update using winget..."
    try {
        Start-Process $WingetPath -ArgumentList 'uninstall --id Dell.CommandUpdate --silent --force' -Wait -NoNewWindow
        Write-Output "Dell Command Update uninstalled successfully using winget."
        return $true
    } catch {
        Write-Output "Failed to uninstall Dell Command Update using winget: $_"
        return $false
    }
}

# Function to install Dell Command Update using winget
function Install-DellCommandUpdateUsingWinget {
    Write-Output "Installing Dell Command Update using winget..."
    try {
        winget source update
        Start-Process $WingetPath -ArgumentList 'install --name Dell.CommandUpdate --silent --force' -Wait -NoNewWindow
        Write-Output "Dell Command Update installed successfully using winget."
        return $true
    } catch {
        Write-Output "Failed to install Dell Command Update using winget: $_"
        return $false
    }
}

# Main script logic
try {
    # Uninstall Dell Command Update if already installed
    if (Uninstall-DellCommandUpdateUsingWinget) {
        Write-Output "Uninstalled Dell Command Update successfully."
    }

    # Install Dell Command Update using winget
    $installSuccess = Install-DellCommandUpdateUsingWinget

    # Set Ninja custom field values for installation status
    if ($installSuccess) {
        Ninja-Property-Set set dellcommandupdateInstalled 'Yes'
    } else {
        Ninja-Property-Set set dellcommandupdateInstalled 'No'
    }
}
catch {
    # Handle errors during installation/uninstallation
    Write-Output "Error during installation/uninstallation process: $_"

    # Set Ninja custom field values on error
    Ninja-Property-Set set dellcommandupdateInstalled 'No'
}
