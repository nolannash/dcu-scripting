# Define the expected path for DCU CLI
$expectedCliPath = 'C:\Program Files\Dell\CommandUpdate\dcu-cli.exe'

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
                        $Patterns | Where-Object { $_ -like $_.Name }
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
            [string]$ExpectedCliPath,  # The exact path to check for the CLI

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [array]$Executables
        )

        $isValid = $false
        $cliFound = $false

        # Check if the expected CLI path exists
        if (Test-Path $ExpectedCliPath) {
            $cliFound = $true
            $isValid = $true
        }

        # Final determination of status based on the search results
        if ($cliFound -and $isValid) {
            Write-Output "DCU Installation Status: Valid `nREASON: CLI found at: `n$ExpectedCliPath"
        }
        elseif (-not $cliFound) {
            Write-Output "DCU Installation Status: Invalid `nREASON: CLI not found at: `n$ExpectedCliPath"
        }
    }
}

# Invoke the script block to define the functions
. $functions

# Execute the search for DCU folders
$dcuFolders = Find-DcuInstallation -Paths $potentialDcuInstallPaths -Patterns $patterns

# Validate the DCU installation by checking the expected path
Test-DcuInstallation -ExpectedCliPath $expectedCliPath -Executables $executables
