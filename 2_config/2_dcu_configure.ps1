# Define registry keys to be modified
$registryKeys = @{
    'DCUconfigured' = 1
}
# The DCUconfigured registry key is used by Dell Command Update (DCU) to track whether the system has been configured by the tool. 
# Specifically, setting this key to 1 indicates that DCU has completed its configuration on the system. 
# This configuration could include settings like disabling update notifications, setting update schedules, 
# or other custom preferences for how DCU manages updates on the device.


# Specify possible paths where dcu-cli.exe might be located
$PossibleDcuCliPaths = @(
    "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe",
    "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
)

# Find dcu-cli.exe
$DcuCliPath = $PossibleDcuCliPaths | Where-Object { Test-Path $_ -PathType Leaf } | Select-Object -First 1

if ($DcuCliPath) {
    try {
        # Backup current registry values
        $backupPath = "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG_Backup"
        if (-not (Test-Path $backupPath)) {
            New-Item -Path $backupPath -Force | Out-Null
        }
        foreach ($key in $registryKeys.Keys) {
            $currentValue = Get-ItemProperty -Path "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG" -Name $key -ErrorAction SilentlyContinue
            if ($currentValue) {
                Set-ItemProperty -Path $backupPath -Name $key -Value $currentValue.$key -Type DWord -Force
            }
        }

        # Update registry values
        foreach ($key in $registryKeys.Keys) {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG" -Name $key -Value $registryKeys[$key] -Type DWord -Force
        }

        # Configure updates notifications
        $process = Start-Process $DcuCliPath -ArgumentList '/configure -lockSettings=enable -updatesNotification=disable -scheduleManual -userConsent=disable -silent -autoSuspendBitlocker=enable' -NoNewWindow -Wait -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Host "Dell Command Update has been configured, the following settings have been applied:`n
            - settings lock = enabled`n
            - update notifications = disabled`n
            - automatic updates = disabled`n
            - user consent = disabled`n
            - automatically suspend bitlocker = enabled
            " -ForegroundColor Green
        } else {
            Write-Host "Error configuring Dell Command Update. Exit code: $($process.ExitCode)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "An error occurred: $_" -ForegroundColor Red
    }
} else {
    Write-Host "DCU CLI not found. Please check if Dell Command Update is installed." -ForegroundColor Yellow
}