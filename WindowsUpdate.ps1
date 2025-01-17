# Check if the script is running as administrator
Function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Output "This script requires administrative privileges. Restarting with elevated permissions..."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Script continues from here with elevated privileges
Write-Output "Running as administrator. Continuing with the script..."

# Perform Windows Updates
Write-Output "Checking for Windows Updates..."
try {
    # Install Windows Update Module if not present
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Output "Installing PSWindowsUpdate module..."
        Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
    }

    # Import the module
    Import-Module PSWindowsUpdate

    # Check for available updates
    $updates = Get-WindowsUpdate
    if ($updates) {
        Write-Output "Updates found. Installing updates..."
        Install-WindowsUpdate -AcceptAll -AutoReboot
    } else {
        Write-Output "No updates found."
    }
} catch {
    Write-Error "Failed to perform Windows Updates: $_"
}