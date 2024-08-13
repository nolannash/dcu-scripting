# Specify possible paths where dcu-cli.exe might be located
$PossibleDcuCliPaths = @(
    "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe",
    "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
)

# Find dcu-cli.exe
$DcuCliPath = $PossibleDcuCliPaths | Where-Object { Test-Path $_ -PathType Leaf } | Select-Object -First 1

if ($DcuCliPath) {
    try {
        #create timestamp
        $now = Get-Date -Format 'yyyy-MM-dd_HH-mm'
        # Check for the log storage location from Ninja
        $NinjaExportPath = Ninja-Property-Get dcuLogLocation
        if (-not (Test-Path -Path $NinjaExportPath)) {
            # If Ninja log location doesn't exist, use default directory
            $ExportDir = "C:\Users\Nolan\Documents\Code\Dell Command Update\logs_and_exports"
            if (-not (Test-Path -Path $ExportDir)) {
                New-Item -Path $ExportDir -ItemType Directory | Out-Null
            }
            #use personal location + timestamp
            $ExportPath = Join-Path $ExportDir "settings_export__1.$now"
        } else {
            # Use the Ninja log location + timestamp
            $ExportPath = Join-Path $NinjaExportPath "settings_export__1.$now"
        }

        # Construct the arguments string
        $arguments = "/configure -exportSettings=`"$ExportPath`""

        # Use Start-Process to run the command
        Write-Output "Running DCU CLI..."
        Start-Process -FilePath $DcuCliPath -ArgumentList $arguments -NoNewWindow -Wait

        Write-Output "Settings exported to: $ExportPath"
    }
    catch {
        Write-Output "Error: $_" -ForegroundColor Red
    }
} else {
    Write-Output "DCU CLI not found. Ensure Dell Command Update is installed." -ForegroundColor Yellow
}
