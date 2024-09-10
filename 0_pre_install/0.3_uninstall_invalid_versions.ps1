# Function to log messages and update status
function Write-Log {
    param(
        [string]$Message,
        [switch]$UpdateStatus
    )
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    if ($UpdateStatus) {
        # Ninja-Property-Set dcuRemovalStatus $Message
        Write-Output "Status Updated: $Message"
    }
}

# Function to remove registry keys
function Remove-RegistryKeys {
    $regPaths = @(
        "HKLM:\SOFTWARE\Dell\UpdateService",
        "HKLM:\SOFTWARE\Dell\CommandUpdate",
        "HKLM:\SOFTWARE\WOW6432Node\Dell\UpdateService",
        "HKLM:\SOFTWARE\WOW6432Node\Dell\CommandUpdate",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DellCommandUpdate",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\DellCommandUpdate"
    )

    foreach ($path in $regPaths) {
        if (Test-Path $path) {
            Write-Log "Removing registry key: $path"
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Search for any remaining Dell Command Update related keys
    $dellKeys = Get-ChildItem "HKLM:\SOFTWARE", "HKLM:\SOFTWARE\WOW6432Node" -Recurse -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -like "*Dell*Command*Update*" }
    foreach ($key in $dellKeys) {
        Write-Log "Removing additional registry key: $($key.Name)"
        Remove-Item -Path $key.PSPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Function to remove services
function Remove-Services {
    $services = Get-WmiObject -Class Win32_Service | Where-Object { $_.Name -like "*DellCommandUpdate*" -or $_.DisplayName -like "*Dell Command Update*" }
    foreach ($service in $services) {
        Write-Log "Stopping and removing service: $($service.Name)"
        Stop-Service -Name $service.Name -Force -ErrorAction SilentlyContinue
        $service.Delete()
    }
}

# Function to remove scheduled tasks
function Remove-ScheduledTasks {
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*Dell*Command*Update*" }
    foreach ($task in $tasks) {
        Write-Log "Removing scheduled task: $($task.TaskName)"
        Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false -ErrorAction SilentlyContinue
    }
}

# Function to remove files and folders
function Remove-FilesAndFolders {
    $paths = @(
        "C:\Program Files\Dell\CommandUpdate",
        "C:\Program Files (x86)\Dell\CommandUpdate",
        "C:\ProgramData\Dell\CommandUpdate"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Write-Log "Removing folder: $path"
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Search for any remaining Dell Command Update related folders
    $dellFolders = Get-ChildItem -Path "C:\Program Files*", "C:\ProgramData" -Recurse -Directory -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -like "*Dell*Command*Update*" }
    foreach ($folder in $dellFolders) {
        Write-Log "Removing additional folder: $($folder.FullName)"
        Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Function to remove Windows Apps packages
function Remove-WindowsAppsPackages {
    $packages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*DellCommandUpdate*" }
    foreach ($package in $packages) {
        Write-Log "Removing Windows Apps package: $($package.PackageFullName)"
        try {
            Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
        }
        catch {
            Write-Log "Failed to remove package using Remove-AppxPackage. Attempting alternative method..."
            try {
                $null = & powershell.exe -NonInteractive -Command "Get-AppxPackage -AllUsers '$($package.Name)' | Remove-AppxPackage -AllUsers"
                Write-Log "Alternative removal method completed."
            }
            catch {
                Write-Log "Failed to remove package using alternative method: $_"
            }
        }
    }

    # Remove provisioned packages
    $provisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*DellCommandUpdate*" }
    foreach ($package in $provisionedPackages) {
        Write-Log "Removing provisioned package: $($package.PackageName)"
        try {
            Remove-AppxProvisionedPackage -PackageName $package.PackageName -Online -ErrorAction Stop
        }
        catch {
            Write-Log "Failed to remove provisioned package: $_"
        }
    }
}

# Function to remove additional files and folders
function Remove-AdditionalFiles {
    $additionalPaths = @(
        "C:\ProgramData\Dell\UpdatePackage\Log",
        "C:\ProgramData\Microsoft\Windows\AppRepository"
    )

    foreach ($path in $additionalPaths) {
        Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | 
        Where-Object { $_.Name -like "*Dell*Command*Update*" } | 
        ForEach-Object {
            Write-Log "Removing additional file: $($_.FullName)"
            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
        }
    }
}

# Main removal function
function Remove-DellCommandUpdateThoroughly {
    Write-Log "Starting thorough removal of Dell Command Update" -UpdateStatus
    
    Write-Log "Removing registry keys..." -UpdateStatus
    Remove-RegistryKeys
    
    Write-Log "Removing services..." -UpdateStatus
    Remove-Services
    
    Write-Log "Removing scheduled tasks..." -UpdateStatus
    Remove-ScheduledTasks
    
    Write-Log "Removing files and folders..." -UpdateStatus
    Remove-FilesAndFolders
    
    Write-Log "Removing Windows Apps packages..." -UpdateStatus
    Remove-WindowsAppsPackages

    Write-Log "Removing additional files..." -UpdateStatus
    Remove-AdditionalFiles

    # Run MSI uninstall commands
    Write-Log "Running MSI uninstall commands..." -UpdateStatus
    $msiCommands = @(
        @{Version = "4.1"; GUID = "{D8D5991F-7A8A-4B1B-9F2C-A91F861F1BD3}" },
        @{Version = "4.2"; GUID = "{2F5D3D9E-9A3B-4AEE-8475-E3D5E7B42900}" },
        @{Version = "4.3"; GUID = "{E9C7D65F-DBAE-4EE7-8F40-3A0AF4D4CFB0}" },
        @{Version = "4.4"; GUID = "{D7366302-C0B3-4834-A473-D0F06BD8AEDF}" },
        @{Version = "4.5"; GUID = "{FFD8CF3D-3063-4D97-B007-26258E71D02F}" },
        @{Version = "4.6"; GUID = "{FFD8CF3D-3063-4D97-B007-26258E71D02F}" },
        @{Version = "4.7"; GUID = "{1309CCD0-A923-4203-8A92-377F37EE2C29}" },
        @{Version = "4.8"; GUID = "{D2E875B4-E71A-4AD2-9E0C-3E097A3D54FC}" },
        @{Version = "4.9"; GUID = "{84F3B225-B7D3-45AC-ACA3-DC21DA802140}" }
    )

    foreach ($cmd in $msiCommands) {
        Write-Log "Attempting to remove Dell Command Update version $($cmd.Version)"
        $process = Start-Process -FilePath "MsiExec.exe" -ArgumentList "/qn", "/norestart", "/X$($cmd.GUID)" -Wait -NoNewWindow -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Log "Successfully removed Dell Command Update version $($cmd.Version)"
        }
        else {
            Write-Log "Failed to remove Dell Command Update version $($cmd.Version). Exit code: $($process.ExitCode)"
        }
    }

    Write-Log "Thorough removal process completed. Performing final check..." -UpdateStatus
}

# Run the thorough removal
Remove-DellCommandUpdateThoroughly

# Final check
$remainingFiles = Get-ChildItem -Path "C:\Program Files*", "C:\ProgramData" -Recurse -ErrorAction SilentlyContinue | 
Where-Object { $_.Name -like "*Dell*Command*Update*" }
$remainingRegKeys = Get-ChildItem "HKLM:\SOFTWARE", "HKLM:\SOFTWARE\WOW6432Node" -Recurse -ErrorAction SilentlyContinue | 
Where-Object { $_.Name -like "*Dell*Command*Update*" }
$remainingServices = Get-WmiObject -Class Win32_Service | Where-Object { $_.Name -like "*DellCommandUpdate*" -or $_.DisplayName -like "*Dell Command Update*" }
$remainingTasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*Dell*Command*Update*" }
$remainingPackages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*DellCommandUpdate*" }

if ($remainingFiles -or $remainingRegKeys -or $remainingServices -or $remainingTasks -or $remainingPackages) {
    Write-Log "Warning: Some Dell Command Update related items may still be present on the system." -UpdateStatus
    if ($remainingFiles) {
        Write-Log "Remaining files or folders:"
        $remainingFiles | ForEach-Object { Write-Log $_.FullName }
    }
    if ($remainingRegKeys) {
        Write-Log "Remaining registry keys:"
        $remainingRegKeys | ForEach-Object { Write-Log $_.Name }
    }
    if ($remainingServices) {
        Write-Log "Remaining services:"
        $remainingServices | ForEach-Object { Write-Log $_.Name }
    }
    if ($remainingTasks) {
        Write-Log "Remaining scheduled tasks:"
        $remainingTasks | ForEach-Object { Write-Log $_.TaskName }
    }
    if ($remainingPackages) {
        Write-Log "Remaining Windows Apps packages:"
        $remainingPackages | ForEach-Object { Write-Log $_.PackageFullName }
    }
    Write-Log "Dell Command Update removal incomplete. Manual intervention may be required." -UpdateStatus
}
else {
    Write-Log "Success: Dell Command Update has been fully and completely removed from the system." -UpdateStatus
}
