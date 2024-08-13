# Specify possible paths where dcu-cli.exe might be located
$PossibleDcuCliPaths = @(
    "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe",
    "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
)

# Find dcu-cli.exe
$DcuCliPath = $PossibleDcuCliPaths | Where-Object { Test-Path $_ -PathType Leaf } | Select-Object -First 1

if ($DcuCliPath) {
    try {
        # Define the export directory and ensure it exists
        $ExportDir = "C:\Users\Nolan\Documents\Code\Dell Command Update\logs_and_exports"
        if (-not (Test-Path -Path $ExportDir)) {
            New-Item -Path $ExportDir -ItemType Directory | Out-Null
        }

        # Create a unique file name with a timestamp
        $Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
        $ExportPath = Join-Path $ExportDir "settings_export__1.$Timestamp"

        # Construct the arguments string
        $arguments = "/configure -exportSettings=`"$ExportPath`""

        # Use Start-Process to run the command
        Write-Host "Running DCU CLI..."
        Start-Process -FilePath $DcuCliPath -ArgumentList $arguments -NoNewWindow -Wait

        Write-Host "Settings exported to: $ExportPath"
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "DCU CLI not found. Ensure Dell Command Update is installed." -ForegroundColor Yellow
}
