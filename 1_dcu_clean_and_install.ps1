$WingetCommand = Get-Command -Name winget.exe -ErrorAction SilentlyContinue

if ($WingetCommand) {
    Write-Host "winget.exe found. Proceeding with Dell Command Update operations..." -ForegroundColor Green

    # Check if Dell Command Update is installed
    $DcuInstalled = Test-Path -Path "C:\Program Files\Dell\CommandUpdate"

    if ($DcuInstalled) {
        Write-Host "Dell Command Update found. Uninstalling and installing the latest version..." -ForegroundColor Green
        
        # Uninstall Dell Command Update
        Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList '/uninstall' -Wait -WindowStyle hidden
        
        # Install the latest version using winget
        Start-Process $WingetCommand.Path -ArgumentList 'install --name Dell.CommandUpdate.Universal --force' -Wait -WindowStyle hidden
    } else {
        Write-Host "Dell Command Update not found. Installing the latest version..." -ForegroundColor Yellow
        
        # Install the latest version using winget
        Start-Process $WingetCommand.Path -ArgumentList 'install --name Dell.CommandUpdate.Universal --force' -Wait -WindowStyle hidden
    }

    Write-Host "Dell Command Update removal and installation completed." -ForegroundColor Green

    #set ninja custom field value
    Ninja-Property-Set dcu_installed 'true'

    $now = Get-Date
    $formattedDateTime = $now.ToString("dd/MM/yyyy [HH:mm:ss]") 
    Ninja-Property-Set last_dcu_install "$formattedDateTime"


} else {
    Write-Host "winget.exe not found. Please ensure that it is installed and included in the system PATH." -ForegroundColor Red
    
}
Pause
