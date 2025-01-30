# Filename: setup.ps1
# Description: PowerShell script to set up a Windows environment with Scoop, Winget, and various tools.
# Usage: Run this script in PowerShell with administrative privileges.

# Function to write colored output
function Write-ColorOutput {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    $colorMap = @{
        "Green" = "32"
        "Red"   = "31"
    }
    $colorCode = $colorMap[$Color]
    Write-Host -ForegroundColor $Color $Message
}

# Ensure the Windows Time service is running and set to start automatically
Set-Service -Name W32Time -Status Running -StartupType Automatic

# Check if Scoop is installed, and install it if not
if (!(Get-Command "scoop" -ErrorAction SilentlyContinue)) {
    Write-ColorOutput -Message "Scoop is not installed. Installing Scoop..." -Color "Green"
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force # Requires confirmation with 'A' (All)
    Invoke-WebRequest -Uri https://get.scoop.sh -UseBasicParsing | Invoke-Expression
} else {
    Write-ColorOutput -Message "Scoop is already installed." -Color "Green"
}

# Check if Winget is installed, and install it via Scoop if not
if (!(Get-Command "winget" -ErrorAction SilentlyContinue)) {
    Write-ColorOutput -Message "Winget is not installed. Installing Winget via Scoop..." -Color "Green"
    scoop install main/winget
} else {
    Write-ColorOutput -Message "Winget is already installed." -Color "Green"
}

# Add required Scoop buckets
$buckets = @(
    "main",
    "extras",
    "versions",
    "nonportable",
    "nerd-fonts",
    "java",
    "games",
    "charm https://github.com/charmbracelet/scoop-bucket.git"
)

# Install Git (required for adding buckets)
scoop install main/git-with-openssh

# Add each bucket if it doesn't already exist
foreach ($bucket in $buckets) {
    try {
        $existingBuckets = scoop bucket list | Select-String -Pattern $bucket
        if ($existingBuckets) {
            Write-ColorOutput -Message "Bucket '$bucket' is already added." -Color "Green"
        } else {
            Write-ColorOutput -Message "Adding bucket '$bucket'..." -Color "Green"
            scoop bucket add $bucket
        }
    } catch {
        Write-ColorOutput -Message "Failed to add bucket '$bucket': $_" -Color "Red"
    }
}

Write-ColorOutput -Message "All buckets processed." -Color "Green"

# Define tools to install via Scoop, categorized by type
$tools = @{
    "CLI Tools" = @(
        "main/starship",
        "main/gsudo",
        "main/ffmpeg",
        "main/hugo-extended",
        "main/restic",
        "main/wget",
        "main/curl",
        "main/uutils-coreutils",
        "main/7zip",
        "main/neovim",
        "main/helix",
        "main/zoxide",
        "main/fzf",
        "main/fd",
        "extras/winmtr",
        "main/nmap",
        "main/bottom",
        "main/bat",
        "main/chezmoi",
        "main/nu",
        "main/eza",
        "main/file",
        "main/grep",
        "main/ripgrep",
        "main/bitwarden-cli",
        "main/gawk",
        "main/which"
    )
    "GUI Productivity" = @(
        "extras/pdfsam",
        "extras/flameshot",
        "extras/flow-launcher",
        "extras/everything",
        "extras/thunderbird",
        "extras/onecommander",
        "extras/simplenote"
    )
    "GUI Development" = @(
        "extras/vscodium",
        "extras/lapce",
        "versions/firefox-developer",
        "extras/windows-terminal",
        "extras/wezterm",
        "nonportable/virtualbox-np"
    )
    "GUI Media" = @(
        "extras/mpc-qt",
        "extras/jellyfin-mpv-shim",
        "extras/makemkv",
        "extras/handbrake"
    )
    "GUI Utilities" = @(
        "extras/teamviewer",
        "extras/etcher",
        "extras/windirstat",
        "extras/bitwarden",
        "extras/clamav",
        "extras/quicklook",
        "extras/komorebi",
        "extras/whkd",
        "extras/f.lux",
        "extras/painter"
    )
    "Gaming" = @(
        "extras/playnite",
        "extras/nvcleanstall",
        "nonportable/logitech-gaming-software-np",
        "versions/steam",
        "games/battlenet"
    )
    "Internet & File Management" = @(
        "extras/winscp",
        "extras/librewolf",
        "extras/nextcloud",
        "extras/transmission"
    )
    "Fonts" = @(
        "nerd-fonts/AnonymousPro-NF-Mono",
        "nerd-fonts/Hack-NF-Mono",
        "nerd-fonts/FiraCode-NF-Mono",
        "nerd-fonts/JetBrainsMono-NF-Mono",
        "nerd-fonts/Meslo-NF-Mono"
    )
}

# Install tools by category
foreach ($category in $tools.GetEnumerator()) {
    Write-ColorOutput -Message "Installing tools for $($category.Key)..." -Color "Green"
    foreach ($tool in $category.Value) {
        # Check if the tool is already installed
        $toolName = ($tool -split "/")[-1] # Extract tool name from bucket/tool format
        if (scoop list | Select-String -Pattern $toolName -Quiet) {
            Write-ColorOutput -Message "$toolName is already installed." -Color "Green"
        } else {
            Write-ColorOutput -Message "Installing $toolName..." -Color "Green"
            scoop install $tool
        }
    }
}

# Install additional packages via Winget
$wingetInstallations = @(
    "Microsoft.PowerShell",
    "Beeper.Beeper",
    "Corsair.iCUE.4",
    "PrivateInternetAccess.PrivateInternetAccess",
    "tailscale.tailscale"
)

Write-ColorOutput -Message "Installing tools with Winget..." -Color "Green"
foreach ($package in $wingetInstallations) {
    # Check if the package is already installed
    if (winget list --id $package -e -q) {
        Write-ColorOutput -Message "$package is already installed." -Color "Green"
    } else {
        Write-ColorOutput -Message "Installing $package..." -Color "Green"
        winget install -e --id $package
    }
}

# Install PSWindowsUpdate module for managing Windows updates
Write-ColorOutput -Message "Installing PSWindowsUpdate module..." -Color "Green"
Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser

# Run Windows updates
Write-ColorOutput -Message "Checking for Windows updates..." -Color "Green"
Get-WindowsUpdate -Install -AcceptAll -AutoReboot

# Prompt for restart if required
if (Test-PendingReboot) {
    Write-ColorOutput -Message "A system restart is required to complete updates." -Color "Red"
    $restart = Read-Host "Do you want to restart now? (Y/N)"
    if ($restart -eq "Y" -or $restart -eq "y") {
        Restart-Computer -Force
    } else {
        Write-ColorOutput -Message "Please restart your system later to complete updates." -Color "Red"
    }
} else {
    Write-ColorOutput -Message "No restart is required at this time." -Color "Green"
}

Write-ColorOutput -Message "Installation process completed!" -Color "Green"

# Manual Installations (not automated)
Write-ColorOutput -Message "Manually install the following:" -Color "Green"
Write-ColorOutput -Message "- Anytype" -Color "Green"
Write-ColorOutput -Message "- FileJuggler" -Color "Green"