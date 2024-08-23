Start-Process -Path "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/scan -updateType=bios,firmware,driver -autoSuspendBitLocker=enable" -outputlog=""C:\Users\$env:username\Desktop\dcuUpdateLog.log"""

Pause