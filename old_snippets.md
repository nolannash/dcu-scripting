--> taken from automated scan file

# $dcuCliPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
# $weeklyLogsFolder = "C:\WeeklyLogs"  # Change the path to your preferred location

# # Check if DCU CLI is installed
# if (Test-Path -Path $dcuCliPath -PathType Leaf) {
#     # Check if the script is running with elevated privileges
#     $elevated = ([Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"
    
#     if (-not $elevated) {
#         # Restart the script with elevated privileges
#         Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
#         Exit
#     }

#     # Run DCU scan and capture results
#     Start-Process $dcuCliPath -ArgumentList "/scan -updateType=bios,firmware,driver,application -outputLog=" -Wait -RedirectStandardOutput "$($env:TEMP)\dcu_output.txt"

#     # Read the content of the output log file
#     $outputLogPath = "$($env:TEMP)\dcu_output.txt"
#     $content = Get-Content -Path $outputLogPath

#     # Create WeeklyLogs folder if it doesn't exist
#     if (-not (Test-Path -Path $weeklyLogsFolder -PathType Container)) {
#         New-Item -ItemType Directory -Path $weeklyLogsFolder -Force
#     }

#     # Export content to a text file with a dynamic name
#     $weeklyLogsFileName = "scan_$(Get-Date -Format 'yyyy-MM-dd').txt"
#     $weeklyLogsFilePath = Join-Path $weeklyLogsFolder $weeklyLogsFileName

#     # Prepare content for the text file
#     foreach ($type in "bios", "firmware", "driver", "application") {
#         if ($content -match "$type.*Pending.*:\s*(\d+)") {
#             $updatesCount = $matches[1]
#             Add-Content -Path $weeklyLogsFilePath -Value "$type has updates ready. Count: $updatesCount"
#         }
#     }

#     Write-Host "DCU scan results exported to $weeklyLogsFilePath."
# }
# else {
#     Write-Host "DCU CLI not found. Please check if Dell Command Update is installed."
# }

# # Keep the PowerShell window open
# Read-Host "Press Enter to exit..."