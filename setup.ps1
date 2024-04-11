# filename: setup.ps1 (can be run via powershell)
# I would need git or download this file directly from github before running this script.

# install scoop
set-executionpolicy remotesigned -scope currentuser

# install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# confirm with A (all)
iwr -useb get.scoop.sh | iex

# preparation of requirements
scoop install git
scoop bucket add extras
scoop bucket add versions

# command line tools and helpers
scoop install sudo 
#scoop install ffmpeg # transcoder similar to handbrake in cli
#scoop install hugo-extended # static website generator
#scoop install rclone # like syncthing
#scoop install restic # simple backup utility
scoop install wget # downloader
scoop install uutils-coreutils # GNU coreutils compiled in Rust
scoop install 7zip # compressor, extracter
scoop install vim # text editor with syntax highlighter
scoop install zoxide # cd on steroides
scoop install winmtr # GUI interface pops up, ping + traceroute functions
scoop install bottom # like htop, top, or btop
scoop install bat # cat replacement
scoop install chezmoi # cross-platform, GNU stow alternative
scoop install eza # exa, ls replacement
scoop install file
scoop install grep
scoop install https://github.com/JanDeDoobeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
scoop install bitwarden-cli
choco install gawk # awk utility

# GUI tools
#scoop install mremoteng # remote connnections manager
scoop install pdfsam # PDF manipulator
scoop install vlc # media player
scoop install vscode # code IDE editor
scoop install bitwarden # password management
scoop install firefox-developer
scoop install windows-terminal
scoop install playnite # games curator of clients like Steam and Ubisoft
scoop install teamviewer
scoop install wingetui
choco install chocolateygui
scoop install onecommander
scoop install mpc-hc
choco install jellyfin-media-player
choco install makeMKV
choco install handbrake
choco install flameshot
choco install flow-launcher
choco install Everything
choco install filejuggler
choco install etcher # balenaEtcher ISO image burner
choco install anytype # object oriented knowledge database used like notion and obsidian
scoop install nvcleaninstall

# internet file management tools
choco install pia
scoop install winscp # FTP, SFTP client
