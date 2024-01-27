<Strong>THIS IS A COPY PASTE FROM A REDDIT THREAD, I STILL NEED TO READ THROUGH THIS </Strong>



support assist
Install or Upgrade Dell Command Update for Windows (EITHER Universal or Not!)
David Szpunar
OP
 — 11/11/2023 1:13 PM
This is a little less complete and clean as I'd prefer because Dell seems to make it difficult to both publicly download from a script and also to extract/use their download directly (unless I'm missing something, maybe it's easier than I made it!) but it works pretty darned reliably to both install and to upgrade/remove older versions of DCU if you repackage both the Universal and Non-Universal Dell Command Update installers as described in the very detailed directions at the top of the script and make them available to download by the script.

The current version of Dell Command Update is 5.1.0 as of this writing. Download links are provided in the script to get them yourself, extract and repackage easily for this install. The installers (Zip and the extracted folder) are deleted from the system after being used by the script on each run. I started with version 4.9.0 and updated to 5.1.0 and it was quite straightforward to repackage and change just the variable in the script to work with the new version!

-Uninstall is there but only very slightly tested, but the top of the script has links to the arguments and you're welcome to figure it out better. NinjaRMM also seems to uninstall Dell Command Update from the Software Inventory quite well.

Use the -ForceDell flag or Script Variable to not quit if Dell hardware isn't detected (the default behavior) and try to install anyway, since sometimes the hardware detection is wrong.

This script does NOT do any DCU configuration or updating of the system using Dell Command Update. It ONLY installs or in-place upgrades the Dell Command Update application itself! There's other documentation from Dell to schedule or force installs of updates periodically once DCU is installed!

Also note that version 4.9.0 was an updated that fixed a major security hole in prior versions, so removing or upgrading to 4.9.0 or later is strongly recommended from a security standpoint.
#Requires -Version 5.1
<#
.SYNOPSIS
    Install or Update the latest Dell Command Update version silently, but only on Dell systems.
.DESCRIPTION
    Install or Update the latest Dell Command Update version silently, but only on Dell systems. See Notes for detailed file prep 
    instructions required before running! You MUST host repackaged Dell installers yourself per the directions provided! In testing, 
    it removes all prior versions of Dell Command Update, but upgrades to the same type (Universal or Non-Universal) as what was 
    installed, if there's already an installation (hence why prepare both, since various machines seem to have various versions 
    already installed and one installer won't upgrade the opposite previous version!).
.EXAMPLE
    (No Parameters)

    Prints basic status, any old version that's being removed during upgrade, and the output result code (0 is success, sometimes also 
    indicates a reboot is required to complete the installation).

.PARAMETER: Uninstall
    TODO: Uninstall Dell Command Update if installed (redimentary implementation, may not work)

.PARAMETER: ForceDell
    Attempt to install even if the detected hardware is not Dell based on motherboard type query.
.EXAMPLE
    Uninstall
    
    Attempt run the uninstall silently command on the Dell Command Update install EXE to remove itself. Not sure if it works, 
    tested only on a very old (2.x) version and it said there wasn't any matching app, but it's pretty good at removing all old 
    versions to install the new. Also, NinjaRMM's Software Inventory has properly Uninstalled most versions of DCU when using the 
    Uninstall command!

    Dell's uninstall directions: https://www.dell.com/support/manuals/en-us/command-update/dellcommandupdate_ug/uninstall-dell-command-%7C-update?guid=guid-35122cc1-21de-4ed6-a28f-709d2fce7df1&lang=en-us
    and https://www.dell.com/support/manuals/en-us/command-update/dellcommandupdate_ug/uninstall-dell-command-%7C-update?guid=guid-35122cc1-21de-4ed6-a28f-709d2fce7df1&lang=en-us
.OUTPUTS
    Basic status of actions taken are printed.
.NOTES
    2023-11-10 - Updated for 5.1.0, changed -ForceDell to switch from string, added Switch Variables support
    2023-06-26 - Initial version for 4.9.0 (unreleased)
    
    HOW TO PREPARE INSTALLTION FILES (because Dell doesn't make it easy to get the installers and I've repackaged them for easy unzipping):
    1. Download Dell Command Update installers for both the Universal and non-Universal versions from:
    https://www.dell.com/support/home/en-us/product-support/product/optiplex-3060-sff/drivers choose Windows 10, 64-bit, expand to show more, 
        locate the "Dell Command | Update Windows Universal Application" entry:
        https://www.dell.com/support/home/en-us/drivers/driversdetails?driverid=jcvw3&oscode=wt64a&productcode=optiplex-3060-sff
            (downloaded file is Dell-Command-Update-Windows-Universal-Application_JCVW3_WIN_5.1.0_A00.EXE)
        Then locate the "Dell Command | Update Application" entry:
        https://www.dell.com/support/home/en-us/drivers/driversdetails?driverid=44th5&oscode=wt64a&productcode=optiplex-3060-sff
            (downloaded file is Dell-Command-Update-Application_44TH5_WIN_5.1.0_A00.EXE)

    2. Download the .exe installers for the Universal and Non-Universal options above, both, to a local folder. Create two folders next to 
    these files, one for the Universal version and one for the non-Universal version, with these names:
        DCU_5.1.0
        DCU_5.1.0-NonUniversal
    
    3. Double-click each of the above files, click the Extract button, and choose the folder above corresponding with each. These instructions 
    should work with most newer versions by changing just the version number; I started with 4.9.0 and the only change was the new installers 
    and the corresponding $current_version variable in the script being changed to match to get 5.1.0 to work.

    4. Right-click one at a time on each of the above folders with the extracted contents, and choose Compress to Zip to make a zip file named 
    the same as the folder, with Windows defaults. The files inside should be untouched from extraction.

    5. Upload these two Zip files to the same folder on an HTTPS-accessible storage that's accessible from the systems running this script.

    6. Change the $download_source variable below to the HTTPS path of the two zip files, leaving the $current_version embedded 
    in the filename and specifying the Universal version (the non-Universal path will be inferred by the script as long as you 
    named the files properly). Like so:
        $download_source = "https://YOURSERVER.com/YOURPATH/DellCommandUpdate\DCU_$current_version.zip";
    
    7. Save this script to NinjaRMM as an Automation and optionally set Script Variables checkboxes for the ForceDell and Uninstall switches.
        (The ForceDell switch will try to install even if the system doesn't specify Dell as the manufacturer, which happens occasionally, and 
        the Uninstall switch will try to uninstall the app, see notes above about this being best-effort and mostly untested.)
    
    8. Run the script on systems to install the application, removing any old versions of Dell Command Update in the process (it hasn't 
    ever not worked on any particular version I've seen, back to 2.x). There's no reason this couldn't be run manually on a local 
    machine if preferred or to test.
#>

[CmdletBinding()]
param (
    [Parameter()][switch] $Uninstall,
    [Parameter()][switch] $ForceDell
)

begin {
    # Cleanup from ImmyBot:
    ##This section was added in order to help "fix" bad factory installs that would actually prevent new/updated DCU installs from working.
    ## Unsure if the problem is the files in this folder or the permissions, but deleting this entire folder allowed the installation to succeed when it previously failed.
    $UpdateServicePath = "$($env:ProgramData)\Dell\UpdateService"
    if (Test-Path $UpdateServicePath) {
        Remove-Item -Path $UpdateServicePath -Force -Recurse -ErrorAction SilentlyContinue
    }


    $current_version = '5.1.0'
    # Replace the entire URL below with your URL to the .zip file, but it MUST be in the format below.
    # You must download the installer, extract it, then zip the installer back up with subfolders as-is for it to work.
    # The non-Universal same version should be unpacked, re-zipped, and uploaded to the same folder with -NonUniversal.zip 
    # as the end of the file. The .exe files inside will differ, but keep them the same as Dell does and the script 
    # will handle them properly.
    $download_source = "https://[REPLACE_WITH_YOUR_HOSTNAME]/installers/DellCommandUpdate\DCU_$current_version.zip";

    $ScriptExitCode = 0 # Default exit code unless error
... (249 lines left)
Collapse
Deploy-Update-DellCommandUpdate-Sharable.ps1
18 KB
David Szpunar
OP
 — 11/15/2023 8:39 AM
Note: it looks like there's a script on the Ninja Dojo to use Dell Command Update to actually trigger an update scan, or an update/install/reboot, which should work well after DCU is installed. I haven't tested it but it looks great! See https://ninjarmm.zendesk.com/hc/en-us/community/posts/14132555849613-Dell-Command-Update-My-Approach

Additionally, a specific script to use DCU to check if BIOS updates are available and store the status in custom fields: https://ninjarmm.zendesk.com/hc/en-us/community/posts/4413851131277-Find-out-if-your-Dell-has-an-available-BIOS-update

A script to force Dell firmware updates with DCU: https://ninjarmm.zendesk.com/hc/en-us/community/posts/4412740022285-Dell-Firmware-Updates-Script

These are all linked from the Script Share: Patch Management scripts overview table at https://ninjarmm.zendesk.com/hc/en-us/articles/360057899071 
Wisecompany — 11/17/2023 10:25 AM
I've got a clean approach to this if you're interested. Should always grab the latest DCU, no staging necessary.

https://scripts.aaronjstevenson.com/device-management/updates/dell-command-update
Dell Command Update
PowerShell script to silently install and run Dell Command Update (DCU).
Dell Command Update
To be clear, my script installs DCU (if missing), configures automatic updates with DCU, and installs all available DCU updates without a reboot.
I generally take the approach of always install all updates and fix potential issues that arise, rather than waiting to install updates. Adjust as necessary based on your approach.
David Szpunar
OP
 — 11/17/2023 11:17 AM
That looks awesome, thanks! I figured it was possible but didn't get as far as figuring it out :-)
Not clear on first look if yours works if either the Universal or Non-Universal is already installed, but otherwise yours looks excellent and maybe I'll switch :-)
Wisecompany — 11/17/2023 11:18 AM
It does. It will also remove Dell Update (a separate, incompatible product) if it is detected.
Here's the portion that detects the correct download URL, if you're interested.
function Get-DownloadURL {
  $DellURL = 'https://www.dell.com/support/kbdoc/en-us/000177325/dell-command-update'
  $Headers = @{ 'accept' = 'text/html' }
  [String]$DellWebPage = Invoke-RestMethod -UseBasicParsing -Uri $DellURL -Headers $Headers
  if ($DellWebPage -match '(https://www\.dell\.com.*driverId=[a-zA-Z0-9]*)') { 
    $DownloadPage = Invoke-RestMethod -UseBasicParsing -Uri $Matches[1] -Headers $Headers
    if ($DownloadPage -match '(https://dl\.dell\.com.*Dell-Command-Update.*\.EXE)') { $Matches[1] }
  }
}
 
It actually has to check 2 separate webpages.
(Thanks Dell)
David Szpunar
OP
 — 11/17/2023 11:22 AM
Yeah I just skimmed it, looks decent enough as long as Dell doesn't break things :-)
Wisecompany — 11/17/2023 11:22 AM
It's been working for a year or so.
David Szpunar
OP
 — 11/17/2023 11:24 AM
Good enough for me. I put it on my todo list to swap mine out in Ninja :-)
Wisecompany — 11/17/2023 11:43 AM
FWIW: Dell retired the non-universal version of DCU with 4.7.1. Their installer handles the removal of previous versions itself. 
David Szpunar
OP
 — 11/17/2023 11:43 AM
You can still download both though, in version 5
And each won't install if the "wrong" version is installed, in my testing, which is why I added support for the second
Wisecompany — 11/17/2023 11:49 AM
Give it a shot with my script and let me know how it goes.
MatDew — 11/19/2023 6:07 AM
Noticed you're downloading and installing regardless of if it's already installed
MatDew — 11/19/2023 6:26 AM
I separated download from install
And in install I adjusted so it catches when in regular or (x86) path.

$DCU = (Resolve-Path "C:\Program Files*\Dell\CommandUpdate\dcu-cli.exe").Path
David Szpunar
OP
 — 11/19/2023 9:45 AM
Interesting—not intentionally downloading if installed, without the -Force flag, but my logic could be wrong!
MatDew — 11/19/2023 12:02 PM
my apologies, I was actually looking at Wisecompany's version
David Szpunar
OP
 — 11/19/2023 12:04 PM
Ahh. Fair enough. I like the way they’ve done it and bypassed my need for repackaging, but I like my switched and options :-)
Wisecompany — 11/28/2023 2:25 PM
I like this adjustment! I'll update mine.

Regarding installing if it's already installed, I do actually check first. 
See this portion:
  $Version = $DownloadURL | Select-String '[0-9]*\.[0-9]*\.[0-9]*' | ForEach-Object { $_.Matches.Value }
  $AppName = 'Dell Command | Update for Windows Universal'
  $App = Get-ChildItem -Path $RegPaths | Get-ItemProperty | Where-Object { $_.DisplayName -like $AppName } | Select-Object
  if ($App.DisplayVersion -ne $Version) {
    Write-Output "Installing Dell Command Update: [$Version]"
    # Install code....
  }
 
The if statement is the relevant bit.
Wisecompany — 11/28/2023 2:28 PM
Slight improvement:
$DCU = (Resolve-Path "$env:SystemDrive\Program Files*\Dell\CommandUpdate\dcu-cli.exe").Path
ogre — 12/07/2023 1:37 PM
Here's my version. I found the Dell bits and adapted it for my needs. 
# Check/Install Updates via Dell Command Update
# Uses Chocolatey to install DCU then checks for and applies updates via DCU

# Test Chocolatey
$testchoco = powershell choco -v
if(-not($testchoco)){
Expand
message.txt
5 KB
MatDew — 12/22/2023 11:51 AM
My fairly simplified approach to install + running with options (uses Winget, which may not be the latest, but should be able to self-update from then on) and expects you to configure 4 script variables in Ninja
Image
Image
Set-Location -Path $env:SystemRoot
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

If ($env:reboot -eq 'true') {
    $rebootOption = 'enable'
} else {
    $rebootOption = 'disable'
}

$biosManufacturer = (Get-ComputerInfo -Property BiosManufacturer).BiosManufacturer
If ($biosManufacturer -match 'Dell') {

    If ($env:installIfNeeded -eq 'True') {
        Try {
            $ResolveWingetPath = Resolve-Path "$env:ProgramW6432\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
            if ($ResolveWingetPath) {
                $Wingetexe = $ResolveWingetPath[-1].Path
            }
            $null = Test-Path $wingetexe
        } catch {
            Write-Warning 'Winget not found'
            Write-Warning $_
            exit 1
        }
        try {
            & $Wingetexe uninstall -e Dell.CommandUpdate --silent --accept-source-agreements
            & $Wingetexe install -e Dell.CommandUpdate.Universal --silent --accept-source-agreements --accept-package-agreements
        } catch {
            Write-Warning 'Unable to install DCU with winget'
            Write-Warning $_
            exit 1
        }
    }

    try {
        $dcuclipath = (Resolve-Path "C:\Program Files*\Dell\CommandUpdate\dcu-cli.exe").Path
        cmd /c "`"$dcuclipath`" /configure -updatesNotification=disable -userConsent=disable -scheduleAuto -silent"
        cmd /c "`"$dcuclipath`" /scan -silent"

        If ($env:silentDriverUpdates -eq 'True') { 
            cmd /c "`"$dcuclipath`" /applyUpdates -silent -updateType=driver,application -reboot=disable"
        }
        If ($env:updateBios -eq 'True') {
            cmd /c "`"$dcuclipath`" /applyUpdates -silent -updateType=bios,firmware -autoSuspendBitLocker=enable -reboot=$rebootOption"
        }
    } catch {
        Write-Warning 'Unable to apply updates using the dcu-cli.'
        Write-Warning $_
        exit 1
    }
} else {
    Write-Warning 'This is not a Dell machine!'
    exit 1
}
Collapse
DCU_Unified.ps1
3 KB
#Requires -Version 5.1
<#
.SYNOPSIS
    Install or Update the latest Dell Command Update version silently, but only on Dell systems.
.DESCRIPTION
    Install or Update the latest Dell Command Update version silently, but only on Dell systems. See Notes for detailed file prep 
    instructions required before running! You MUST host repackaged Dell installers yourself per the directions provided! In testing, 
    it removes all prior versions of Dell Command Update, but upgrades to the same type (Universal or Non-Universal) as what was 
    installed, if there's already an installation (hence why prepare both, since various machines seem to have various versions 
    already installed and one installer won't upgrade the opposite previous version!).
.EXAMPLE
    (No Parameters)

    Prints basic status, any old version that's being removed during upgrade, and the output result code (0 is success, sometimes also 
    indicates a reboot is required to complete the installation).

.PARAMETER: Uninstall
    TODO: Uninstall Dell Command Update if installed (redimentary implementation, may not work)

.PARAMETER: ForceDell
    Attempt to install even if the detected hardware is not Dell based on motherboard type query.
.EXAMPLE
    Uninstall
    
    Attempt run the uninstall silently command on the Dell Command Update install EXE to remove itself. Not sure if it works, 
    tested only on a very old (2.x) version and it said there wasn't any matching app, but it's pretty good at removing all old 
    versions to install the new. Also, NinjaRMM's Software Inventory has properly Uninstalled most versions of DCU when using the 
    Uninstall command!

    Dell's uninstall directions: https://www.dell.com/support/manuals/en-us/command-update/dellcommandupdate_ug/uninstall-dell-command-%7C-update?guid=guid-35122cc1-21de-4ed6-a28f-709d2fce7df1&lang=en-us
    and https://www.dell.com/support/manuals/en-us/command-update/dellcommandupdate_ug/uninstall-dell-command-%7C-update?guid=guid-35122cc1-21de-4ed6-a28f-709d2fce7df1&lang=en-us
.OUTPUTS
    Basic status of actions taken are printed.
.NOTES
    2023-11-10 - Updated for 5.1.0, changed -ForceDell to switch from string, added Switch Variables support
    2023-06-26 - Initial version for 4.9.0 (unreleased)
    
    HOW TO PREPARE INSTALLTION FILES (because Dell doesn't make it easy to get the installers and I've repackaged them for easy unzipping):
    1. Download Dell Command Update installers for both the Universal and non-Universal versions from:
    https://www.dell.com/support/home/en-us/product-support/product/optiplex-3060-sff/drivers choose Windows 10, 64-bit, expand to show more, 
        locate the "Dell Command | Update Windows Universal Application" entry:
        https://www.dell.com/support/home/en-us/drivers/driversdetails?driverid=jcvw3&oscode=wt64a&productcode=optiplex-3060-sff
            (downloaded file is Dell-Command-Update-Windows-Universal-Application_JCVW3_WIN_5.1.0_A00.EXE)
        Then locate the "Dell Command | Update Application" entry:
        https://www.dell.com/support/home/en-us/drivers/driversdetails?driverid=44th5&oscode=wt64a&productcode=optiplex-3060-sff
            (downloaded file is Dell-Command-Update-Application_44TH5_WIN_5.1.0_A00.EXE)

    2. Download the .exe installers for the Universal and Non-Universal options above, both, to a local folder. Create two folders next to 
    these files, one for the Universal version and one for the non-Universal version, with these names:
        DCU_5.1.0
        DCU_5.1.0-NonUniversal
    
    3. Double-click each of the above files, click the Extract button, and choose the folder above corresponding with each. These instructions 
    should work with most newer versions by changing just the version number; I started with 4.9.0 and the only change was the new installers 
    and the corresponding $current_version variable in the script being changed to match to get 5.1.0 to work.

    4. Right-click one at a time on each of the above folders with the extracted contents, and choose Compress to Zip to make a zip file named 
    the same as the folder, with Windows defaults. The files inside should be untouched from extraction.

    5. Upload these two Zip files to the same folder on an HTTPS-accessible storage that's accessible from the systems running this script.

    6. Change the $download_source variable below to the HTTPS path of the two zip files, leaving the $current_version embedded 
    in the filename and specifying the Universal version (the non-Universal path will be inferred by the script as long as you 
    named the files properly). Like so:
        $download_source = "https://YOURSERVER.com/YOURPATH/DellCommandUpdate\DCU_$current_version.zip";
    
    7. Save this script to NinjaRMM as an Automation and optionally set Script Variables checkboxes for the ForceDell and Uninstall switches.
        (The ForceDell switch will try to install even if the system doesn't specify Dell as the manufacturer, which happens occasionally, and 
        the Uninstall switch will try to uninstall the app, see notes above about this being best-effort and mostly untested.)
    
    8. Run the script on systems to install the application, removing any old versions of Dell Command Update in the process (it hasn't 
    ever not worked on any particular version I've seen, back to 2.x). There's no reason this couldn't be run manually on a local 
    machine if preferred or to test.
#>

[CmdletBinding()]
param (
    [Parameter()][switch] $Uninstall,
    [Parameter()][switch] $ForceDell
)

begin {
    # Cleanup from ImmyBot:
    ##This section was added in order to help "fix" bad factory installs that would actually prevent new/updated DCU installs from working.
    ## Unsure if the problem is the files in this folder or the permissions, but deleting this entire folder allowed the installation to succeed when it previously failed.
    $UpdateServicePath = "$($env:ProgramData)\Dell\UpdateService"
    if (Test-Path $UpdateServicePath) {
        Remove-Item -Path $UpdateServicePath -Force -Recurse -ErrorAction SilentlyContinue
    }


    $current_version = '5.1.0'
    # Replace the entire URL below with your URL to the .zip file, but it MUST be in the format below.
    # You must download the installer, extract it, then zip the installer back up with subfolders as-is for it to work.
    # The non-Universal same version should be unpacked, re-zipped, and uploaded to the same folder with -NonUniversal.zip 
    # as the end of the file. The .exe files inside will differ, but keep them the same as Dell does and the script 
    # will handle them properly.
    $download_source = "https://[REPLACE_WITH_YOUR_HOSTNAME]/installers/DellCommandUpdate\DCU_$current_version.zip";

    $ScriptExitCode = 0 # Default exit code unless error

    # Tests that the script is elevated
    function Test-IsElevated {
        $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $p = New-Object System.Security.Principal.WindowsPrincipal($id)
        $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    }

    function Test-RegistryValue {
        param (
            [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]$Key,
            [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]$Name
        )

        try {
            # Get-ItemProperty -Path $Key | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null return $true }
            Get-ItemPropertyValue -Path $Key -Name $Name }
        catch {
            return $false
        }
    }

    function Test-UniversalOrClassic {
        $Key = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings"
        $Name = "AppCode"
        $CUType = Test-RegistryValue -Key $key -Name $Name -ErrorAction Ignore
        $RegVersion = Test-RegistryValue -Key $Key -Name "ProductVersion" -ErrorAction Ignore
        if ($CUType -eq 'Classic') {
            # Write-Host "The Classic Dell Command Update version is installed, switching to Non Universal version."
            return $CUType, $RegVersion
        } elseif ($CUType -eq 'Universal') {
            # Write-Host "The Universal Dell Command Update version is installed, continuing with Universal version."
            return "", $RegVersion
        } else {
            # Write-Host "Registry value is not Universal or Classic, likely not installed. Continuing."
            return "", ""
        }
    }

    function Test-MfgIsDell {
        if ($(Get-ComputerInfo -Property 'CsManufacturer') -like "*Dell*") {
            write-host "This is a Dell computer, continuing."
        } elseif ($ForceDell) {
            Write-Host "This computer is NOT self-reporting as a Dell, but due to the -ForceDell parameter we're going to continue anyway."
        } else {
            write-host "This is NOT a Dell computer, quitting."
            exit 1
        }
    }

    function Test-AlreadyInstalled {
        param (
            [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]$CurrentVersion
        )

        ($ainst_cutype, $ainst_version) = Test-UniversalOrClassic
        if($ainst_cutype -eq 'Classic') {
            if($ainst_version -ne $CurrentVersion) {
                Write-Host "The installed version" $ainst_version "is not the current $CurrentVersion version."
            } else {
                Write-Host "The current Classic version $CurrentVersion is installed and current already, quitting."
                exit 0
            }
        } else {
            $InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
            foreach($obj in $InstalledSoftware) {
                # write-host $obj.GetValue('DisplayName') -NoNewline
                # write-host " - " -NoNewline
                # write-host $obj.GetValue('DisplayVersion')
                if($obj.GetValue('DisplayName') -eq "Dell Command | Update for Windows Universal") {
                    Write-Host $obj.GetValue('DisplayName') "is installed."
                    if($obj.GetValue('DisplayVersion') -ne $CurrentVersion) {
                        Write-Host "The installed version" $obj.GetValue('DisplayVersion') "is not the current $CurrentVersion version."
                        # return $false
                    } else {
                        Write-Host "The current Universal version $CurrentVersion is installed already, quitting."
                        exit 0
                    }
                }
            }
        }
        # If we got here, the app isn't installed at all, continuing is OK
    }

    function Invoke-InstallerDownload {
        param (
            [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]$InstallerURL,
            [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]$CurrentVersion
        )
        # Configure preferred TLS versions in order and disable progress bar to speed downloads.
        $AllProtocols = ([System.Net.SecurityProtocolType]).DeclaredMembers |where-object {'Ssl3','Tls','Tls11','Tls12' -contains $_.Name} | Select-Object -ExpandProperty Name
        if($null -eq $AllProtocols)
        {
        $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls'
        }
        [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
        $ProgressPreference = 'SilentlyContinue'

        $path = "$env:TEMP"
        $filename = "DCU_$CurrentVersion"
        $destination = "$path\$filename.zip";
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($InstallerURL, $destination)

        if (Test-Path -PathType Leaf -Path $destination) {
            Write-Host "Installer downloaded to $destination "
        } else {
            Write-Host "Failed to download installer, bye."
            exit 1
        }

        Expand-Archive -Path $destination -DestinationPath "$path" -Force

        # $path_version = $CurrentVersion.Replace('.', '_')
        $extracted_exe = "$path\$filename\DellCommandUpdateApp_Setup.exe"
        if($NonUniversal -ne '') {
            $path_version = $CurrentVersion.Replace('.', '_')
            $extracted_exe = "$path\$filename-NonUniversal\DCU_Setup_$path_version.exe"
        }

        # Write-Host "PATHS:" 
        # Write-Host "Extracted EXE: " $extracted_exe
        # Write-Host "Destination: " $destination
        # Write-Host "Extracted Folder: " "$path\$filename"
        if (Test-Path -PathType Leaf -Path $extracted_exe) {
            Write-Host "Installer extracted to $extracted_exe "
        } else {
            Write-Host "Failed to extract installer to '$extracted_exe', bye."
            exit 1
        }

        # Return the EXE path, the downloaded ZIP file, and the extracted folder path
        return $extracted_exe, $destination, "$path\$filename"
    }

    # # Is it Windows 10 or 11 or something else?
    # $WindowsVersion = [System.Environment]::OSVersion.Version.Major

    # # Current Build Number
    # $BuildNumber = [System.Environment]::OSVersion.Version.Build

    # If Script Variables are used grab the input
    if($env:uninstall -eq 'true'){ $Uninstall = $true }
    if($env:forceDell -eq 'true') { $ForceDell = $true }
}
process {

    # If not elevated error out. Admin priveledges are required to create HKLM registry keys
    if (-not (Test-IsElevated)) {
        Write-Error -Message "Access Denied. Please run with Administrator privileges."
        exit 1
    }

    # Only install or update Dell Command Update on Dell brand computers.
    Test-MfgIsDell

    # Only install or update if the current version is not already installed.
    if(!$Uninstall) {
        Test-AlreadyInstalled -CurrentVersion $current_version
    }

    ($NonUniversal, $RegVersion) = Test-UniversalOrClassic
    if($NonUniversal -ne '') {
        # $NonUniversal = Test-UniversalOrClassic
        # if($NonUniversal -ne '') {
            Write-Host "Switching to Classic installer to match existing version."
            $download_source = $download_source.Replace("$current_version","$current_version-NonUniversal")
        # }
    }

    ($InstallerFile, $InstallerZip, $InstallerFolder) = Invoke-InstallerDownload -InstallerURL $download_source -CurrentVersion $current_version
    $InstallerLogFile = [IO.Path]::GetTempFileName()
    $Arguments = @"
/s /l="$InstallerLogFile"
"@
    if($Uninstall) {
        # start-process -FilePath msiexec.exe -ArgumentList "/x $((Get-Package | Where-Object {$_.Name -li
        #     ke "Dell Command | Update*"}).fastpackagereference) /qn /norestart"
        $Arguments = @"
/passthrough /x /s /v"/qn" /l="$InstallerLogFile"
"@
    }
    # Write-Host "Installer log file: $InstallerLogFile"
    # Write-Host "Installing or uninstalling '$InstallerFile' with this argument list:"
    # Write-Host $Arguments
    if($Uninstall) {
        Write-Host "Attempting to uninstall with installation package..."
    } else {
        Write-Host "Attempting installation or upgrade..."
    }
    $Process = Start-Process -Wait $InstallerFile -ArgumentList $Arguments -PassThru
    $ExitCode = $Process.ExitCode
    If($ExitCode -ne 0)
    {
        Write-Host (Get-Content -Tail 200 $InstallerLogFile | Out-String)
    }
    Write-Host "ExitCode: $ExitCode"
    if($ExitCode -eq 5 -or $ExitCode -eq 3010)
    {
        Write-Host "Exit Code $ExitCode indicates a restart is required to finish installation."
        # Set-PendingRebootFlag
    }
    if($ExitCode -eq 1602)
    {
        Write-Host "Exit Code 1602 indicates the update is not correct for the system."
        Write-Host "Try re-running passing -NonUniversal with a true value and re-running to install the non-universal version."
        $ScriptExitCode = 1     # Still want to clean up, but exit with error as install did not complete.
    }

}
end {
    #cleanup
    if (Test-Path -PathType Leaf -Path $InstallerZip) {
        Remove-Item $InstallerZip -Force
        # Write-Host "Deleted temporary installer '$InstallerZip' from system."
    } else {
        Write-Host "No installer zip file '$InstallerZip' exists, not trying to remove."
    }
    if (Test-Path -PathType Container -Path $InstallerFolder) {
        Remove-Item -Recurse -Force $InstallerFolder
        # Write-Host "Deleted temporary install folder '$InstallerFolder' from system."
    } else {
        Write-Host "No temporary folder '$InstallerFolder' exists, not trying to remove."
    }

    $ScriptName = "Install or Update the latest Dell Command Update version silently, but only on Dell systems."
    $ScriptVariables = @(
        [PSCustomObject]@{
            name           = "Undo"
            calculatedName = "undo"
            required       = $false
            defaultValue   = $false
            valueType      = "CHECKBOX"
            valueList      = $null
            description    = "Whether or not install or uninstall Dell Command Update"
        },
        [PSCustomObject]@{
            name           = "Force Dell"
            calculatedName = "forceDell"
            required       = $false
            defaultValue   = $false
            valueType      = "CHECKBOX"
            valueList      = $null
            description    = "Whether to force installation even on hardware not detected as Dell automatically"
        }
    )
    exit $ScriptExitCode
}

