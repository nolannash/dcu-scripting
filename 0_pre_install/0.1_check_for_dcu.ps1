# Define the CLI executable name
$cliExecutable = 'dcu-cli.exe'

# Define potential locations where DCU can be found
$potentialDcuInstallPaths = @(
    'C:\Program Files\WindowsApps\',
    'C:\Program Files (x86)\Dell\',
    'C:\Program Files\Dell\'
)

# Patterns to detect various naming conventions for Dell Command Update
$patterns = @(
    "*dell*command*update*", "*command*update*", "*dcu*", "*DellCommandUpdate*",
    "*Dell*Update*", "*DellInc.*CommandUpdate*", "*Dell.*CommandUpdate*",
    "DellCommandUpdate_*", "*CommandUpdate*_*_*"
)

# Function to recursively search for the CLI executable
function Find-CliExecutable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [string]$Executable
    )

    $cliPath = $null
    try {
        $cliPath = Get-ChildItem -Path $Path -Recurse -Filter $Executable -ErrorAction Stop | 
            Select-Object -First 1 -ExpandProperty FullName
    }
    catch {
        Write-Warning "Error searching in path: $Path. Error: $_"
    }
    return $cliPath
}

# Function to locate DCU installation folders and validate installation
function Test-DcuInstallation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [array]$Paths,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [array]$Patterns,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$CliExecutable
    )
    
    $dcuFound = $false
    $cliFound = $false
    $cliPath = $null

    foreach ($path in $Paths) {
        if (Test-Path $path) {
            try {
                $folders = Get-ChildItem -Path $path -Directory -Recurse -ErrorAction Stop | 
                    Where-Object { 
                        $folder = $_.FullName
                        ($Patterns | Where-Object { $folder -like $_ }) -ne $null
                    }
                
                if ($folders) {
                    $dcuFound = $true
                    foreach ($folder in $folders) {
                        $cliPath = Find-CliExecutable -Path $folder.FullName -Executable $CliExecutable
                        if ($cliPath) {
                            $cliFound = $true
                            break
                        }
                    }
                }
                if ($cliFound) { break }
            }
            catch {
                Write-Warning "Error searching in path: $path. Error: $_"
            }
        }
        else {
            Write-Verbose "Path not found: $path"
        }
    }

    if (-not $dcuFound) {
        Write-Output "DCU Installation Status: Not Installed`nREASON: No Dell Command Update folders found"
    }
    elseif ($cliFound) {
        Write-Output "DCU Installation Status: Valid`nREASON: CLI found at: $cliPath"
    }
    else {
        Write-Output "DCU Installation Status: Invalid`nREASON: Dell Command Update folder found, but CLI not present"
    }
}

# Main execution
Test-DcuInstallation -Paths $potentialDcuInstallPaths -Patterns $patterns -CliExecutable $cliExecutable
