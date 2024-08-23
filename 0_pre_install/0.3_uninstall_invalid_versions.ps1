# Function to find non-CLI Dell Command Update installations
function Find-NonCliDellCommandUpdate {
    $possiblePaths = @(
        "C:\Program Files\Dell\CommandUpdate",
        "C:\Program Files (x86)\Dell\CommandUpdate"
    )
    $customPaths = Get-ChildItem -Path "C:\Program Files*\Dell\*" -Recurse -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -eq "DellCommandUpdate.exe" } | 
    Select-Object -ExpandProperty DirectoryName

    $allPaths = @($possiblePaths + $customPaths) | Where-Object { Test-Path $_ } | Select-Object -Unique

    # Filter out paths that contain dcu-cli.exe
    return $allPaths | Where-Object {
        -not (Test-Path (Join-Path $_ "dcu-cli.exe"))
    }
}

# Function to get the uninstall string for non-CLI Dell Command Update
function Get-NonCliDcuUninstallString {
    $uninstallKeys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    foreach ($key in $uninstallKeys) {
        $app = Get-ItemProperty -Path $key | Where-Object { 
            ($_.DisplayName -like "*Dell Command | Update*" -or $_.DisplayName -like "*Dell Command Update*") -and
            ($_.DisplayName -notlike "*CLI*")
        }
        if ($app) {
            return $app.UninstallString
        }
    }
    return $null
}

# Function to uninstall non-CLI Dell Command Update
function Uninstall-NonCliDellCommandUpdate {
    $uninstallString = Get-NonCliDcuUninstallString
    if ($uninstallString) {
        Write-Output "Non-CLI DCU uninstall string found: $uninstallString"
        
        # Extract the path and any arguments
        if ($uninstallString -match '^"(.+?)"(.*)$') {
            $uninstallerPath = $matches[1]
            $uninstallerArgs = $matches[2].Trim()
        }
        else {
            $uninstallerPath = $uninstallString
            $uninstallerArgs = ""
        }
        
        # Add silent uninstall arguments if not present
        if ($uninstallerArgs -notlike "*/silent*") {
            $uninstallerArgs += " /silent"
        }
        
        Write-Output "Attempting to uninstall non-CLI Dell Command Update..."
        try {
            $process = Start-Process -FilePath $uninstallerPath -ArgumentList $uninstallerArgs -Wait -NoNewWindow -PassThru
            if ($process.ExitCode -eq 0) {
                Write-Output "Non-CLI Dell Command Update uninstalled successfully."
                return $true
            }
            else {
                Write-Output "Uninstallation failed with exit code: $($process.ExitCode)"
                return $false
            }
        }
        catch {
            Write-Output "Error during uninstallation: $_"
            return $false
        }
    }
    else {
        Write-Output "Non-CLI DCU uninstall string not found. Attempting manual removal."
        return Remove-NonCliDcuManually
    }
}

# Function to manually remove non-CLI Dell Command Update
function Remove-NonCliDcuManually {
    $dcuPaths = Find-NonCliDellCommandUpdate
    foreach ($path in $dcuPaths) {
        try {
            if (Test-Path $path) {
                Remove-Item -Path $path -Recurse -Force
                Write-Output "Removed non-CLI Dell Command Update from: $path"
            }
        }
        catch {
            Write-Output "Failed to remove from $path : $_"
        }
    }
    
    # Remove registry entries (be cautious not to remove CLI-related entries)
    $registryPaths = @(
        "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate",
        "HKLM:\SOFTWARE\Dell\CommandUpdate"
    )
    foreach ($regPath in $registryPaths) {
        if (Test-Path $regPath) {
            # Check if this is not a CLI-related registry key
            $cliRelated = Get-ItemProperty -Path $regPath -Name "*CLI*" -ErrorAction SilentlyContinue
            if (-not $cliRelated) {
                Remove-Item -Path $regPath -Recurse -Force
                Write-Output "Removed registry entry: $regPath"
            }
        }
    }
    
    return $true
}

# Main script logic
try {
    $nonCliDcuInstallations = Find-NonCliDellCommandUpdate
    if ($nonCliDcuInstallations) {
        Write-Output "Non-CLI Dell Command Update is installed. Proceeding with uninstallation."
        $uninstallSuccess = Uninstall-NonCliDellCommandUpdate
        if ($uninstallSuccess) {
            Write-Output "Non-CLI Dell Command Update has been successfully uninstalled."
        }
        else {
            Write-Output "Failed to uninstall non-CLI Dell Command Update."
        }
    }
    else {
        Write-Output "Non-CLI Dell Command Update is not installed."
    }
}
catch {
    Write-Output "An unexpected error occurred: $_"
}

# Final check to confirm uninstallation of non-CLI versions
$remainingNonCliInstallations = Find-NonCliDellCommandUpdate
if (-not $remainingNonCliInstallations) {
    Write-Output "Confirmed: Non-CLI Dell Command Update is not present on the system."
}
else {
    Write-Output "Warning: Non-CLI Dell Command Update may still be present on the system. Locations found: $($remainingNonCliInstallations -join ', ')"
}

# Check for CLI version
$cliPath = Get-ChildItem -Path "C:\Program Files*\Dell\CommandUpdate" -Recurse -ErrorAction SilentlyContinue | 
Where-Object { $_.Name -eq "dcu-cli.exe" } | 
Select-Object -First 1 -ExpandProperty FullName

if ($cliPath) {
    Write-Output "CLI version of Dell Command Update found at: $cliPath"
}
else {
    Write-Output "CLI version of Dell Command Update not found. You may need to install it separately."
}