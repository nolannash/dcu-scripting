# Define runnable versions of DCU CLI
$cliDCU = 'dcu-cli.exe'
$appDCU = 'DellCommandUpdate.exe'

$executables = @(
    $cliDCU,
    $appDCU
)

# Define potential locations where DCU can be found
$winAppsPath = 'C:\Program Files\WindowsApps\'
$progFiles86Path = 'C:\Program Files (x86)\Dell\'
$progFilePath = 'C:\Program Files\Dell\'
$potentialDcuInstallPaths = @(
    $winAppsPath,
    $progFiles86Path,
    $progFilePath
)

# Patterns to detect various naming conventions for Dell Command Update
$patterns = @(
    "*dell*command*update*",
    "*command*update*",
    "*dcu*",
    "*DellCommandUpdate*",
    "*Dell*Update*",
    "*DellInc.*CommandUpdate*",
    "*Dell.*CommandUpdate*",
    "DellCommandUpdate_*",
    "*CommandUpdate*_*_*"
)

# Wrap functions in a script block
$functions = {
    # Function to locate DCU installation folders
    function Find-DcuInstallation {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [array]$Paths,    # Array of paths to search through

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [array]$Patterns  # Array of patterns to match against
        )
        
        # Storage for found locations
        $dcuLocations = @()

        foreach ($path in $Paths) {
            # Check each path to see if it exists
            if (Test-Path $path) {
                try {
                    # Look for directories matching the patterns
                    $folders = Get-ChildItem -Path $path -Directory -Recurse -ErrorAction Stop |
                    Where-Object { 
                        $folder = $_.Name
                        $Patterns | Where-Object { $folder -like $_ }
                    }
                    if ($folders) {
                        foreach ($folder in $folders) {
                            $dcuLocations += $folder.FullName
                        }
                    }
                }
                catch {
                    Write-Warning "Error searching in path: $path. `nError: $_"
                }
            }
            else {
                Write-Warning "Path not found: $path"
            }
        }
        return $dcuLocations
    }

    # Function to validate DCU installation
    function Test-DcuInstallation {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [array]$DcuFolders,

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [array]$Executables
        )

        $isValid = $false
        $dcuFound = $false
        $invalidDueToWinApps = $false

        foreach ($folder in $DcuFolders) {
            if ($folder -like "*WindowsApps*") {
                $dcuFound = $true
                $invalidDueToWinApps = $true
                continue
            }

            if ($folder -like "*Program Files*Dell*") {
                $dcuFound = $true
                $cliFound = $false
                foreach ($exe in $Executables) {
                    if ($exe -eq $cliDCU) {
                        try {
                            $foundExe = Get-ChildItem -Path $folder -Recurse -Filter $exe -ErrorAction Stop
                            if ($foundExe) {
                                $cliFound = $true
                                $isValid = $true
                                break
                            }
                        } catch {
                            Write-Warning "Error searching for $exe in $folder. `nError: $_"
                        }
                    }
                }
                if ($cliFound) {
                    Write-Output "DCU Installation Status: Valid `nREASON: CLI found at: `n$folder"
                } else {
                    Write-Output "DCU Installation Status: Invalid `nREASON: No CLI present at: `n$folder"
                }
            }
        }

        if (-not $dcuFound) {
            Write-Output "DCU Installation Status:Invalid `nREASON: DCU not found"
        }
        elseif ($invalidDueToWinApps) {
            Write-Output "DCU Installation Status: Invalid `nREASON: WindowsApps installation at: `n$folder"
        }
    }
}

# Invoke the script block to define the functions
. $functions

# Execute the search for DCU folders
$dcuFolders = Find-DcuInstallation -Paths $potentialDcuInstallPaths -Patterns $patterns

# Validate the found DCU installation folders
Test-DcuInstallation -DcuFolders $dcuFolders -Executables $executables
