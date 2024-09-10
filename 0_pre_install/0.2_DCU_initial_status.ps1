# Define the CLI executable name
$cliExecutable = 'dcu-cli.exe'

# Define potential locations where DCU can be found
$potentialDcuInstallPaths = @(
    'C:\Program Files\WindowsApps\',
    'C:\Program Files (x86)\Dell\',
    'C:\Program Files\Dell\'
)

# Patterns to detect Dell Command Update
$dcuPatterns = @(
    "*Dell*Command*Update*",
    "*DellCommandUpdate*",
    "DCU*",
    "*Command*Update*"
)

# Patterns to detect conflicting Dell applications
$conflictingAppPatterns = @(
    "*Dell Update*",
    "*DellUpdate*",
    "*Dell SupportAssist*",
    "*DellSupportAssist*"
)

# Function to write verbose output
function Write-VerboseOutput {
    param([string]$Message)
    Write-Verbose $Message
    # Add logging to a file if needed
    # Add-Content -Path "log.txt" -Value $Message
}

# Function to recursively search for the CLI executable with limited depth
function Find-CliExecutable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [string]$Executable,
        [int]$MaxDepth = 3
    )

    $cliPath = $null
    try {
        $cliPath = Get-ChildItem -Path $Path -Recurse -Filter $Executable -Depth $MaxDepth -ErrorAction Stop | 
            Select-Object -First 1 -ExpandProperty FullName
    }
    catch {
        Write-VerboseOutput "Error searching in path: $Path. Error: $_"
    }
    return $cliPath
}

# Function to check if a folder matches any of the given patterns
function Test-FolderMatchesPattern {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FolderPath,
        [Parameter(Mandatory=$true)]
        [array]$Patterns
    )
    
    foreach ($pattern in $Patterns) {
        if ($FolderPath -like $pattern) {
            return $true
        }
    }
    return $false
}

# Function to check for conflicting applications
function Test-ConflictingApps {
    param (
        [Parameter(Mandatory=$true)]
        [array]$Paths,
        [Parameter(Mandatory=$true)]
        [array]$Patterns
    )

    foreach ($path in $Paths) {
        if (Test-Path $path) {
            try {
                $conflictingFolders = Get-ChildItem -Path $path -Directory -Recurse -Depth 2 -ErrorAction Stop | 
                    Where-Object { Test-FolderMatchesPattern -FolderPath $_.FullName -Patterns $Patterns }
                
                if ($conflictingFolders) {
                    return $true
                }
            }
            catch {
                Write-VerboseOutput "Error searching for conflicting apps in path: $path. Error: $_"
            }
        }
    }
    return $false
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
        [array]$DcuPatterns,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$CliExecutable,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [array]$ConflictingPatterns
    )
    
    $result = [PSCustomObject]@{
        DCUFound = $false
        CLIFound = $false
        ConflictingAppFound = $false
        CLIPath = $null
        Status = ""
        Reason = ""
    }

    # Check for conflicting applications first
    $result.ConflictingAppFound = Test-ConflictingApps -Paths $Paths -Patterns $ConflictingPatterns
    if ($result.ConflictingAppFound) {
        $result.Status = "Invalid"
        $result.Reason = "Conflicting Dell application found"
        Ninja-Property-Set dellCommandUpdateInstalled "INVALID: Dell Update Detected"
        return $result
    }

    # Check for DCU installation
    foreach ($path in $Paths) {
        if (Test-Path $path) {
            try {
                $folders = Get-ChildItem -Path $path -Directory -Recurse -Depth 2 -ErrorAction Stop | 
                    Where-Object { Test-FolderMatchesPattern -FolderPath $_.FullName -Patterns $DcuPatterns }
                
                if ($folders) {
                    $result.DCUFound = $true
                    foreach ($folder in $folders) {
                        $cliPath = Find-CliExecutable -Path $folder.FullName -Executable $CliExecutable
                        if ($cliPath) {
                            $result.CLIFound = $true
                            $result.CLIPath = $cliPath
                            break
                        }
                    }
                }

                if ($result.CLIFound) { break }
            }
            catch {
                Write-VerboseOutput "Error searching in path: $path. Error: $_"
            }
        }
        else {
            Write-VerboseOutput "Path not found: $path"
        }
    }

    # Determine installation status
    if (-not $result.DCUFound) {
        $result.Status = "Not Installed"
        $result.Reason = "No Dell Command Update folders found"
        Ninja-Property-Set dellCommandUpdateInstalled "NO: DCU not present"
    }
    elseif ($result.DCUFound -and -not $result.CLIFound) {
        $result.Status = "Invalid"
        $result.Reason = "Dell Command Update folder found, but CLI not present"
        Ninja-Property-Set dellCommandUpdateInstalled "INVALID: no cli"
    }
    elseif ($result.CLIFound) {
        $result.Status = "Valid"
        $result.Reason = "CLI found at: $($result.CLIPath)"
        Ninja-Property-Set dellCommandUpdateInstalled "YES: no config"
    }

    return $result
}

# Function to get the current value of the custom field
function Get-CustomFieldValue {
    try {
        $currentValue = Ninja-Property-Get dellCommandUpdateInstalled
        return $currentValue
    }
    catch {
        Write-VerboseOutput "Error getting custom field value: $_"
        return $null
    }
}

# Main execution
$currentValue = Get-CustomFieldValue

if ($currentValue -eq "YES: configured") {
    Write-Output "DCU is already configured. Skipping installation check."
}
else {
    $result = Test-DcuInstallation -Paths $potentialDcuInstallPaths -DcuPatterns $dcuPatterns -CliExecutable $cliExecutable -ConflictingPatterns $conflictingAppPatterns
    Write-Output "DCU Installation Status: $($result.Status)"
    Write-Output "REASON: $($result.Reason)"
}
