# Script to collect Dell Command Update Status Information

function Collect-DCUStatus {
    # $logPath = Ninja-Property-Get dcuLogLocation
    # $logFile = $logPath
    $logFile = "C:\dcuReport.txt"
    Write-Output "Collecting Dell Command Update Status Information..." | Out-File $logFile

    # Check running processes
    $processes = Get-Process | Where-Object { $_.Name -like "*DellCommand*" -or $_.Name -like "*DCU*" }
    if ($processes) {
        Write-Output "`nRunning Processes:" | Out-File $logFile -Append
        $processes | ForEach-Object { Write-Output $_.Name | Out-File $logFile -Append }
    }

    # Check AppX packages
    $packages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*DellCommandUpdate*" -or $_.PackageFullName -like "*DellInc.DellCommandUpdate*" }
    if ($packages) {
        Write-Output "`nAppX Packages:" | Out-File $logFile -Append
        $packages | ForEach-Object { Write-Output $_.PackageFullName | Out-File $logFile -Append }
    }

    # Check provisioned packages
    $provPackages = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*DellCommandUpdate*" }
    if ($provPackages) {
        Write-Output "`nProvisioned Packages:" | Out-File $logFile -Append
        $provPackages | ForEach-Object { Write-Output $_.PackageName | Out-File $logFile -Append }
    }

    # Check registry keys
    $dellKeys = Get-ChildItem "HKLM:\SOFTWARE", "HKLM:\SOFTWARE\WOW6432Node", "HKCU:\SOFTWARE" -Recurse -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like "*Dell*Command*Update*" -or $_.Name -like "*DellInc.DellCommandUpdate*" }
    if ($dellKeys) {
        Write-Output "`nRegistry Keys:" | Out-File $logFile -Append
        $dellKeys | ForEach-Object { Write-Output $_.Name | Out-File $logFile -Append }
    }

    # Check for scheduled tasks
    $dellTasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*Dell*Command*Update*" -or $_.Name -like "*DellInc.DellCommandUpdate*" }
    if ($dellTasks) {
        Write-Output "`nScheduled Tasks:" | Out-File $logFile -Append
        $dellTasks | ForEach-Object { Write-Output $_.TaskName | Out-File $logFile -Append }
    }

    # Check for services
    $dellServices = Get-Service | Where-Object { $_.DisplayName -like "*Dell*Command*Update*" -or $_.Name -like "*DellInc.DellCommandUpdate*" }
    if ($dellServices) {
        Write-Output "`nServices:" | Out-File $logFile -Append
        $dellServices | ForEach-Object { Write-Output $_.DisplayName | Out-File $logFile -Append }
    }

    Write-Output "DCU status report saved to: $logFile" | Out-File $logFile -Append
}

# Collect the status
Collect-DCUStatus
