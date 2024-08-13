# Function to download and install Dell Command Update using the installer from Dell's website
function Install-DellCommandUpdateUsingInstaller {
    $installerUrl = "https://downloads.dell.com/FOLDER11563484M/1/Dell-Command-Update-Windows-Universal-Application_P83K5_WIN_5.3.0_A00.EXE"
    $installerPath = "$env:TEMP\DCU_Setup.exe"
    
    Write-Output "Downloading Dell Command Update installer..."
    try {
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
        Write-Output "Installing Dell Command Update using downloaded installer..."
        Start-Process -FilePath $installerPath -ArgumentList '/s' -Wait -NoNewWindow
        Write-Output "Dell Command Update installed successfully using the downloaded installer."
        Remove-Item $installerPath -Force
        return $true
    } catch {
        Write-Output "Failed to install Dell Command Update using the downloaded installer: $_"
        return $false
    }
}

# Function to uninstall Dell Command Update by deleting installation directories
function Uninstall-DellCommandUpdate {
    $installPaths = @(
        "C:\Program Files\Dell\CommandUpdate",
        "C:\Program Files (x86)\Dell\CommandUpdate"
    )
    foreach ($path in $installPaths) {
        if (Test-Path -Path $path) {
            Write-Output "Dell Command Update found at $path. Uninstalling..."
            try {
                Remove-Item -Path $path -Recurse -Force
                Write-Output "Uninstalled Dell Command Update successfully from $path."
            } catch {
                $errorMessage = $_.Exception.Message
                Write-Output ("Failed to uninstall Dell Command Update from " + $path + ": " + $errorMessage)
            }
        }
    }
}

# Main script logic
try {
    # Uninstall Dell Command Update if already installed
    Uninstall-DellCommandUpdate

    # Install using the installer from Dell's website
    $installSuccess = Install-DellCommandUpdateUsingInstaller

    # Set 'dcuInstallStatus' property for installation status
    if ($installSuccess) {
        Ninja-Property-Set set dcuInstallStatus 'Success'
        Write-Output 'Dell Command Update successfully installed'
    } else {
        Ninja-Property-Set set dcuInstallStatus 'Failure'
    }
}
catch {
    # Handle errors during installation/uninstallation
    Write-Output "Error during installation/uninstallation process: $_"

    # Set 'dcuInstallStatus' property on error
    Ninja-Property-Set set dcuInstallStatus 'Failure'
}
