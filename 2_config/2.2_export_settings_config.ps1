# Specify possible paths where dcu-cli.exe might be located
$PossibleDcuCliPaths = @(
    "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe",
    "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
)

# Find dcu-cli.exe
$DcuCliPath = $PossibleDcuCliPaths | Where-Object { Test-Path $_ -PathType Leaf } | Select-Object -First 1

if ($DcuCliPath) {
    try {
        $now = Get-Date -Format "mm-dd-yyyy"
        # Define the export path
        $ExportPath = "C:\Users\Nolan\Documents\Code\Dell Command Update\logs_and_exports\DCU_Settings$now"

        # Construct the arguments string
        $arguments = "/configure -exportSettings=`"$ExportPath`""

        # Use Start-Process to run the command
        Write-Host "Executing: $DcuCliPath $arguments"
        Start-Process -FilePath $DcuCliPath -ArgumentList $arguments -NoNewWindow

        Write-Host "Command executed. Please check Dell Command Update to verify the changes."
    }
    catch {
        Write-Host "An error occurred: $_" -ForegroundColor Red
    }
} else {
    Write-Host "DCU CLI not found. Please check if Dell Command Update is installed." -ForegroundColor Yellow
}
