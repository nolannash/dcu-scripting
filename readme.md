# Dell Command Update Automation Project

## Overview

This repository contains scripts and configurations for automating the deployment, configuration, and scanning processes using Dell Command | Update (DCU). The project aims to streamline the management of Dell devices within an MSP (Managed Service Provider) environment. For best results scripts should be run as administrator. The scripts also assume you are using the NinjaOneRMM platform, but can be easily modified to ignore that. 

## Project Structure

### Part 1: Downloading, Installing, and Configuring Dell Command | Update

#### Folder 1: `1_install_dcu`

- `1_dcu_install_url.ps1`: This script has been lightly tested. It first checks to see if DCU is already installed and then uninstalls it if it is detected. The script uses the download URL of the Command Update installer for the most recent version of Dell Command Update as of 5/24/2024
- `1.1_dcu_install_s3.ps1`: This script has not been tested, however it is nearly identical in functionality to the first and tested functional installation script. The script is configured to take a link to an installer stored in an AWS S3 bucket instead of pulling from the Dell website
- `1.2_dcu_install_winget.ps1`: This script has been tested and is currently non-operational. There is an existing winget command to install command update but for an unknown reason it is very tricky to get working

### Part 2 Configuring Dell Command | Update

#### Folder 2: `2_config`

- `2_dcu_configure.ps1`: Configures DCU CLI settings. It disables certain notifications, reboots, and user consents. *
  
#### File 2.5: BIOS Password Management

- `2.5_dcu_admin_bios.ps1`: This script handles BIOS passwords and related configurations. Please note that this part of the script was salvaged from an online source. **Needs review and testing.**

### File 2.1: create logs storage folder

- `2.1_create_logs_storage_folder.ps1`: this takes in a path as a parameter and creates a storage folder at the specified location. This is where all of the logs get stored after scanning

### Folder 3 `3_scans`

#### File 3: Manual Scan Script

- `3_dcu_scan_all.ps1`: Runs a scan for all possible update types using the CLI. Stores the output to the log storage folder --> path taken from Ninja custom fields. Additionally it is set up to analyze the response code and determine if an update is needed on the device. 

### Folder 4: `4_apply_updates`

### File 4.1: Update All

- `4.1_dcu_update_no_reboot.ps1`: Runs a scan and then update of all update types that do not require the comptuer to reboot in order to apply. Saves logs to storage folder.  

### File 4.2: Update BIOS

- `4.2_dcu_update_reboot.ps1`: scans for and applys updates to all update types including those that require a reboot to apply. forcers a reboot after
