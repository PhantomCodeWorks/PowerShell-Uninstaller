

$ProgramName = Read-Host -Prompt "Enter the program name to search for"

# If for all users
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
Where-Object { $_.DisplayName -match "$ProgramName" } | 
Select-Object DisplayName, UninstallString | 
Select-Object @{Name='Location';Expression={'All Users'}}, DisplayName, UninstallString

# If for current user
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
Where-Object { $_.DisplayName -match "$ProgramName" } | 
Select-Object DisplayName, UninstallString | 
Select-Object @{Name='Location';Expression={'Current User'}}, DisplayName, UninstallString

# Include 32 bit programs on a 64 bit system
Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
Where-Object { $_.DisplayName -match "$ProgramName" } | 
Select-Object DisplayName, UninstallString | 
Select-Object @{Name='Location';Expression={'32-bit Programs'}}, DisplayName, UninstallString