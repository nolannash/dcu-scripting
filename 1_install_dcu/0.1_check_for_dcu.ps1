$searchDirectory = "C:\Program Files\WindowsApps"

# Define a list of patterns to match different variants
$patterns = @(
    "dell.*command.*update",       # Matches "Dell Command Update" with variations
    "command.*update",             # Matches "CommandUpdate" without "Dell"
    "DellCommandUpdate",           # Matches "DellCommandUpdate" exactly
    "CommandUpdate"                # Matches "CommandUpdate" exactly
)

# Initialize an array to hold matching items
$matchingItems = @()

# Recursively search through the directory
Get-ChildItem -Path $searchDirectory -Recurse | ForEach-Object {
    foreach ($pattern in $patterns) {
        if ($_ -match $pattern) {
            # Add the full path of the matching item to the array
            $matchingItems += $_.FullName
            break  # Stop checking other patterns if one matches
        }
    }
}

# Combine matching items into a single string with each item on a new line
$matchingItemsText = $matchingItems -join "`n"

# If any matches were found, set the NinjaRMM property
if ($matchingItemsText) {
    Ninja-Property-Set dellCommandUpdateInstalled "Yes, incorrect install, current installation will not allow use of CLI. Found the following items:`n$matchingItemsText"
} else {
    Write-Output "Unable to find any versions of Dell Command Update"
}
