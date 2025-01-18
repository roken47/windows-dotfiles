# Ensure gsudo is installed and available
if (!(Get-Command "gsudo" -ErrorAction SilentlyContinue)) {
    Write-Error "gsudo is not installed. Please install gsudo before running this script."
    exit 1
}

# Define the commands to run with gsudo
$scoopCommand = "scoop update --all"
$wingetCommand = "winget upgrade --all"
$chocoCommand = "choco upgrade all --yes"

# Run the commands with gsudo
try {
    Write-Output "Updating Scoop packages..."
    gsudo $scoopCommand

    Write-Output "Updating Winget packages..."
    gsudo $wingetCommand

    Write-Output "Updating Chocolatey packages..."
    gsudo $chocoCommand
} catch {
    Write-Error "An error occurred while updating packages: $_"
    exit 1
}

Write-Output "Package updates completed successfully."
