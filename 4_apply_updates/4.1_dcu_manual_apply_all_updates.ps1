$dcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
$updateTypes = @("bios", "firmware", "driver", "application")  # Add more types as needed

if (Test-Path $dcuCliPath -PathType Leaf) {
    Write-Host "Dell Command Update CLI found. Proceeding with updates..." -ForegroundColor Green

    foreach ($type in $updateTypes) {
        # Run a scan for a specific update type
        $scanResult = Start-Process -FilePath $dcuCliPath -ArgumentList "/scan -updateType=$type -autoSuspendBitLocker=enable" -Wait -PassThru

        if ($scanResult.ExitCode -eq 1) {
            Write-Host "Updates found for $type. Applying updates..." -ForegroundColor Green

            # Apply updates for a specific type without reboot
            Start-Process -FilePath $dcuCliPath -ArgumentList "/applyUpdates -updateType=$type -reboot=disable -outputlog=C:\Users\$env:username\Desktop\dcuUpdateLog_$type.log" -Wait -NoNewWindow -WindowStyle Hidden

            Write-Host "$type updates applied successfully." -ForegroundColor Green
        } else {
            Write-Host "No updates found for $type." -ForegroundColor Green
        }
    }
} else {
    Write-Host "Error: Dell Command Update CLI (dcu-cli.exe) not found at $dcuCliPath." -ForegroundColor Red
}
Pause