# Specify possible paths where dcu-cli.exe might be located
$PossibleDcuCliPaths = @(
    "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe",
    "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
)

# Find dcu-cli.exe
$DcuCliPath = $PossibleDcuCliPaths | Where-Object { Test-Path $_ -PathType Leaf } | Select-Object -First 1

if ($DcuCliPath) {
    try {
        # Create timestamp
        $now = Get-Date -Format 'yyyy-MM-dd_HH-mm'

        # Hardcoded export directory
        $ExportDir = "#### ADD YOUR PATH ####"  # Replace this with your desired export directory path

        # Check if the export directory exists, if not create it
        if (-not (Test-Path -Path $ExportDir)) {
            New-Item -Path $ExportDir -ItemType Directory | Out-Null
        }

        # Use the specified export directory with timestamp
        $ExportPath = Join-Path $ExportDir "settings_export__1.$now"

        # Construct the arguments string
        $arguments = "/configure -exportSettings=`"$ExportPath`""

        # Use Start-Process to run the command
        Write-Output "Running DCU CLI..."
        Start-Process -FilePath $DcuCliPath -ArgumentList $arguments -NoNewWindow -Wait

        Write-Output "Settings exported to: $ExportPath"
    } catch {
        Write-Output "Error: $_" -ForegroundColor Red
    }
} else {
    Write-Output "DCU CLI not found. Ensure Dell Command Update is installed." -ForegroundColor Yellow
}
