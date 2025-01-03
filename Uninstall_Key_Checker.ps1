function Search {

    $ProgramName = Read-Host -Prompt "Enter the program name to search for"

    $RegistryPaths = @(
        @{Path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"; Location="All Users (64-bit)"},
        @{Path="HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"; Location="All Users (32-bit)"},
        @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"; Location="Current User"}
    )

    foreach ($RegistryPaths in $RegistryPaths) {
        Get-ItemProperty -Path $RegistryPaths.Path | 
        Where-Object { $_.DisplayName -match "$ProgramName" } | 
        Select-Object DisplayName, UninstallString | 
        Select-Object @{Name='Location';Expression={$RegistryPaths.Location}}, DisplayName, UninstallString
    }
}

function Destroy {
    $ProgramName = Read-Host -Prompt "Enter the program name to destroy. Warning: program name must match display name exactly"
    
    # Initialize Array to store uninstall strings along with results
    $UninstallStrings = @()

    $RegistryPaths = @(
        @{Path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"; Location="All Users (64-bit)"},
        @{Path="HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"; Location="All Users (32-bit)"},
        @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"; Location="Current User"}
    )

    foreach ($RegistryPaths in $RegistryPaths) {
        $QueryResults = Get-ItemProperty -Path $RegistryPaths.Path | 
        Where-Object { $_.DisplayName -ceq "$ProgramName" } | 
        Select-Object DisplayName, UninstallString
        if ($QueryResults) { 
            $UninstallStrings += $QueryResults
        }
    }

    # No Options to uninstall
    if ($UninstallStrings.Count -eq 0) {
        Write-Host "No uninstall strings were returned for your query."
        return Main
    }
    
    # Display options to uninstall along with numbers
    Write-Host "Uninstall Options:"
    $Counter = 1
    $UninstallStrings | ForEach-Object {
        Write-Host "$Counter. $($_.DisplayName)"
        Write-Host "    Uninstall String: $($_.UninstallString)"
        $Counter++
    }
    
    # Prompt user to destroy a program
    $DestroySelection = Read-Host -Prompt "Enter the number for the program would you like to destroy"
    
    # Selection Validation
    if ($DestroySelection -notmatch '^\d+$' -or $DestroySelection -lt 1 -or $DestroySelection -gt $UninstallStrings.Count) {
        Write-Host "Invalid selection. Exiting."
        return Main
    }
    
    # Run the selected uninstall string
    $ToBeDestroyed = $UninstallStrings[$DestroySelection - 1].UninstallString
    
    # Destroy the selected application
    if ($ToBeDestroyed) {
        Write-Host "Executing your request to destroy using the uninstall string"
        Write-Host $ToBeDestroyed
        if ($ToBeDestroyed -match "msiexec.exe") {
            # Directly execute MSI uninstall strings
            Start-Process -FilePath "msiexec.exe" -ArgumentList ($ToBeDestroyed -replace "msiexec.exe\s*", "") -Wait
        } else {
            # Wrap non-MSI uninstall strings in cmd.exe
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c $ToBeDestroyed" -Wait
        }    
    }
    }

function Main {
    $Search_or_Destroy = Read-Host -Prompt "Would you like to search or destroy? Destroy will uninstall the program (you must know the exact display name). Search will search the host for the display name and uninstall string"

    if ($Search_or_Destroy -eq "search"){
        Search
    }

    elseif ($Search_or_Destroy -eq "destroy") {
        Destroy
    }

    else{
        Write-Host "Invalid Selection. Please choose search or destroy."
    }
}

do {
    Main | Out-Host
    $Continue = Read-Host -Prompt "Would you like to keep using this program? (yes/no)"
}
while ($Continue -match "^(y|yes)$")
