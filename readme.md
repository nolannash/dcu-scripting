Part 1:
Dowloading, Installing and Configuring Dell Command | Update
- create a policy or group that encompasses all Dell devices
- create a script (Need to decide if we want this done automatically or manually) that checks to see if Dell Command | Update is already installed
--> if DCU is not installed then it will download and install
--> if DCU is installed, it will update it to the latest version
- Once DCU is installed a follow up script will configure the settings
--> there are two ways to do this, we can use the GUI on a single device to create an exportable XML template of the settings configuration
--> the other way we can do this is as part of a script where we go through and programatically declare the configuration we want
--> Both ways have their merrits, but what this does allow for is us to customize the behaviors surrounding updates, reboots, scans and timing.

Part 2:
Scanning for updates by type and exporting to a custom field in ninja
- goal is for two tied together/similar scripts
--> one that runs automatically at a set date time: this will be a similar script to the one that extracts the bitlocker key, it will run at a certain time automatically and will either read a log document with pending updates as created by the DCU scan or will perform the scan itself and will upload the results to a custom field in ninja
----> something along the lines of "Last DCU scan performed: ___" "DCU Scan Results: bios: y, firmware: n, etc."
--> create a second version that is similar to above but is intended to be done manually (if device needs to be scanned for updates as possible solution to issue)

Part 3:
Closely tied to part two, this is where we can decide to do a client by client basis when it comes to automatically downloading and rebooting.
There are two posibilities when it comes to this script
--> first is a manually triggered scan + update (there should be a way to add parameters that allow selective installation, assuming that the part 2 scanning automations work properly)
--> the other way would be to set a timeframe for the script to run (once a month, on a Friday at 9:00pm etc.) at that time, automate a scan + apply updates (if needed could selectively scan/apply updates to only specific things)