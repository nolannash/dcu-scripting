# Dell Command Update Automation Project

## Overview

This repository contains scripts and configurations for automating the deployment, configuration, and scanning processes using Dell Command | Update (DCU). The project aims to streamline the management of Dell devices within an MSP (Managed Service Provider) environment. For best results scripts should be run as administrator

## Project Structure

### Part 1: Downloading, Installing, and Configuring Dell Command | Update

#### File 1: DCU Download and Install

- `1_dcu_clean_and_install`: This script requires testing to ensure functionality. It is intended to be the first script to run. The purpose is to check the device for the existence of ANY version of DCU. If it does not find it, it installs it. If it finds DCU on the device, it completely uninstalls and then reinstalls with the most up-to-date version. The deletion and reinstallation ensure that no files, configuration settings, etc., remain on a device. This script is meant to be run either when a device is first set up for a user to ensure that DCU is on the device, if DCU is directly presenting an error, or a major patch comes out to DCU. **Should be functional, but needs testing**

### Part 2 Configuring Dell Command | Update

#### File 2: DCU Configuration (Assuming it is already installed)

- `2_dcu_configure.ps1`: Configures DCU CLI settings. It disables certain notifications, reboots, and user consents. **Needs further testing and confirmation with G/M to ensure configuration accuracy.**

#### File 2.5: BIOS Password Management

- `2.5_dcu_admin_bios.ps1`: This script handles BIOS passwords and related configurations. Please note that this part of the script was salvaged from an online source. **Needs review and testing.**

### Part 3 Using Dell Command | Update to scan for updates

#### File 3: Manual Scan Script

- `3_dcu_scan_manual.ps1`: Manually initiates a DCU scan with specified update types (bios, firmware, driver) and auto-suspends BitLocker. scan results should be exported directly to Ninja as a custom field and saved to the device as part of a file/folder. This script is for clients who do not want auto-scanning or if a tech believes that a scan is needed to check for updates. Can also be set to run on a timer to create automation. Custom fields in ninja will be created to show scan status/timing/any updates found **Might need further work.**

#### File 3.5: Automated Scan Script

- `dcu_scan_automated.ps1`: This script might be redundant as script 3 can be run both manually or on a set schedule outlined either in ninja console or configuration of DCU **Awaiting confirmation of 3.0 success/failure**

### Part 4

### File 4.1: Update All

- `4.1_dcu_update_all.ps1`: Updates all components using DCU. **Needs further work.**

### File 4.2: Update BIOS

- `4.2_dcu_update_bios.ps1`: Updates the BIOS using DCU. **Needs further work.**

### File 4.3: Update Firmware

- `4.3_dcu_update_firmware.ps1`: Updates firmware using DCU. **Needs further work.**

### File 4.4: Update Drivers

- `4.4_dcu_update_drivers.ps1`: Updates drivers using DCU. **Needs further work.**

### File 4.5: Update Applications

- `4.5_dcu_update_applications.ps1`: Updates applications using DCU. **Needs further work.**

### Additional Notes/Content



