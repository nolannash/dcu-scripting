# Function to check if Dell Command Update is installed
function Test-DellCommandUpdateInstalled {
    $installPaths = @(
        "C:\Program Files\Dell\CommandUpdate",
        "C:\Program Files (x86)\Dell\CommandUpdate"
    )
    foreach ($path in $installPaths) {
        if (Test-Path -Path $path) {
            return $true
        }
    }
    return $false
}

# Function to get the uninstall string for Dell Command Update
function Get-DcuUninstallString {
    $uninstallKeys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    foreach ($key in $uninstallKeys) {
        $app = Get-ItemProperty -Path $key | Where-Object { $_.DisplayName -like "*Dell Command | Update*" }
        if ($app) {
            return $app.UninstallString
        }
    }
    return $null
}

# Function to uninstall Dell Command Update
function Uninstall-DellCommandUpdate {
    $uninstallString = Get-DcuUninstallString
    if ($uninstallString) {
        Write-Host "Uninstall string found: $uninstallString"
        
        # Extract the path and any arguments
        if ($uninstallString -match '^"(.+?)"(.*)$') {
            $uninstallerPath = $matches[1]
            $uninstallerArgs = $matches[2].Trim()
        } else {
            $uninstallerPath = $uninstallString
            $uninstallerArgs = ""
        }
        
        # Add silent uninstall arguments if not present
        if ($uninstallerArgs -notlike "*/silent*") {
            $uninstallerArgs += " /silent"
        }
        
        Write-Host "Attempting to uninstall Dell Command Update..."
        try {
            $process = Start-Process -FilePath $uninstallerPath -ArgumentList $uninstallerArgs -Wait -NoNewWindow -PassThru
            if ($process.ExitCode -eq 0) {
                Write-Host "Dell Command Update uninstalled successfully."
                return $true
            } else {
                Write-Host "Uninstallation failed with exit code: $($process.ExitCode)"
                return $false
            }
        } catch {
            Write-Host "Error during uninstallation: $_"
            return $false
        }
    } else {
        Write-Host "Uninstall string not found. Manual removal may be required."
        return $false
    }
}

# Main script logic
try {
    if (Test-DellCommandUpdateInstalled) {
        Write-Host "Dell Command Update is installed. Proceeding with uninstallation."
        $uninstallSuccess = Uninstall-DellCommandUpdate
        if ($uninstallSuccess) {
            Ninja-Property-Set dcuUninstallStatus "Success"
            Write-Host "Dell Command Update has been successfully uninstalled."
        } else {
            Ninja-Property-Set dcuUninstallStatus "Failure"
            Write-Host "Failed to uninstall Dell Command Update."
        }
    } else {
        Write-Host "Dell Command Update is not installed."
        Ninja-Property-Set dcuUninstallStatus "Not Installed"
    }
} catch {
    Write-Host "An unexpected error occurred: $_"
    Ninja-Property-Set dcuUninstallStatus "Script Error"
}

# Final check to confirm uninstallation
if (-not (Test-DellCommandUpdateInstalled)) {
    Write-Host "Confirmed: Dell Command Update is not present on the system."
} else {
    Write-Host "Warning: Dell Command Update may still be present on the system. Manual check recommended."
}