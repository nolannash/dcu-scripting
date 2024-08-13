
# Specify possible paths where dcu-cli.exe might be located
$PossibleDcuCliPaths = @(
    "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe",
    "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
)

# Find dcu-cli.exe
$DcuCliPath = $PossibleDcuCliPaths | Where-Object { Test-Path $_ -PathType Leaf } | Select-Object -First 1

if ($DcuCliPath) {
    try {
        #setting should be either enable or disable

        # Change the setting
        $arguments = "/configure -lockSettings=enable"
        Write-Host "Executing: $DcuCliPath $arguments"
        Start-Process $DcuCliPath -ArgumentList $arguments -NoNewWindow -Wait

        Write-Host "Command executed. Please check Dell Command Update to verify the changes."
    }
    catch {
        Write-Host "An error occurred: $_" -ForegroundColor Red
    }
} else {
    Write-Host "DCU CLI not found. Please check if Dell Command Update is installed." -ForegroundColor Yellow
}