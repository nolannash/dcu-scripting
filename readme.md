# Dell Command Update Automation Project

## Overview

This repository contains scripts and configurations for automating the deployment, configuration, and scanning processes using Dell Command | Update (DCU). The project aims to streamline the management of Dell devices within an MSP (Managed Service Provider) environment.

## Project Structure

### Part 1: Downloading, Installing, and Configuring Dell Command | Update

#### File 1.1: DCU Download and install

-`dcu_clean_and_install`: As of now this file needs cleaning and testing, eventually this will be the first script that gets run,
the intention of this script is to check the device for the existance of ANY version of DCU, and if it does not find it install it, if it does find DCU on the device it completely uninstalls and then reinstalls with most up to date version.

The deletion and reinstallation is done to ensure that no files, configuration settings etc. remain on a device --> this script is meant to be run either when a device is first setup for a user to ensure that DCU is on the device, if DCU is directly presenting an error or a major patch comes out to DCU

#### File 1.2: DCU Configuration (Assuming it is already installed)

- `dcu_configure.ps1`: Configures DCU CLI settings assuming DCU is already installed. It disables certain notifications, reboots, and user consents.

<strong>Needs work + check with G/M to confirm config</strong>

#### File 2.1: Manual Scan Script

- `dcu_scan_manual.ps1`: Manually Initiates a DCU scan with specified update types (bios, firmware, driver) and auto-suspends BitLocker. Decide if scan results exported directly to ninja as custom field or saved to device as part of a file/folder. This is for clients who do not want auto scanning for whatever reason, or if a Tech believe that a scan is needed to check for updates.

<strong>NEEDS WORK</strong>

#### File 2.2: Automated Scan Script

- `dcu_scan_automated.ps1`:automated version of the above script --> timing can be configured either in DCU configure (if this is the case there is a chance we dont need this file or its purpose changes from DOING the scan and the rest to simply processing the results) or Ninja depending 

<strong>NEEDS WORK</strong>

#### File (?): Automated Export of Scan Results to Ninja 

- `does not exist yet`:May not be needed, but potential positon for a script acting in the middle of the scan, its results, where those are stored and how those results are brought to and displayed in the Ninja Console

#### File 3.1: Application of Updates + Reboot Management 
- `does not exist yet`: similar to step 2/file 2 there is the posibility of slightly simplifying this in the sense that we can automate via the configuration a {time frame} scan then update application and reboot on whatever date and time is wanted however that is harder to configure than having ninja manage the timing. 
Manual version will essentiall just be a second scan and application of updates (with or without reboot not sure) that can be triggered remotely --> ninja might even be able to just have that be the one that gets run on automated timer as part of scanning and updating AND also use it as the manual case by case version.

