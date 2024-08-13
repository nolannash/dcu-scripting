# Function to download and install Dell Command Update using the installer from an AWS S3 bucket
function Install-DellCommandUpdateUsingS3 {
    $installerUrl = ""
    $installerPath = "$env:TEMP\DCU_Setup.exe"
    
    Write-Output "Downloading Dell Command Update installer from S3..."
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

# Main script logic
try {
    # Check if Dell Command Update is already installed
    $dcuPath = "C:\Program Files\Dell\CommandUpdate"
    $DcuInstalled = Test-Path -Path $dcuPath

    if ($DcuInstalled) {
        Write-Output "Dell Command Update found. Uninstalling..."
        try {
            Start-Process "$dcuPath\dcu-cli.exe" -ArgumentList '/uninstall /quiet' -Wait -NoNewWindow
            Write-Output "Uninstalled Dell Command Update successfully."
        } catch {
            Write-Output "Failed to uninstall Dell Command Update: $_"
        }
    } else {
        Write-Output "Dell Command Update not found. Proceeding with installation..."
    }

    # Install using the installer from S3
    $installSuccess = Install-DellCommandUpdateUsingS3

    # Set Ninja custom field values for successful installation
    if ($installSuccess) {
        Ninja-Property-Set set dellcommandupdateInstalled 'Yes'
    } else {
        Ninja-Property-Set set dellcommandupdateInstalled 'No'
    }
}
catch {
    # Handle errors during installation
    Write-Output "Error during installation process: $_"

    # Set Ninja custom field values on error
    Ninja-Property-Set set dellcommandupdateInstalled 'No'
}
