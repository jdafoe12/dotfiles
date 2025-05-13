#!/usr/bin/zsh

# This is meant to be run after setting up a boot manager (such as systemd-boot) and loading into the system as a user (with sudo installed and relevant permissions granted), with a working TTY where zsh is installed.

# This script also assumes that a working internet connection has been established.

usage() {
    echo "Usage: $0 [minimal|userland|full]"
    echo "  minimal: Install only the packages required for dotfiles to work"
    echo "  userland: Install dotfiles packages plus common userland applications"
    echo "  full:    Install everything including display manager, system services, etc."
    echo ""
    echo "You must specify an installation type."
    exit 1
}

# Check for arguments
if [[ $# -gt 0 ]]; then
    if [[ $1 == "minimal" || $1 == "userland" || $1 == "full" ]]; then
        INSTALL_TYPE=$1
    else
        usage
    fi
else
    usage
fi

echo "Installation type: ${INSTALL_TYPE}"
sleep 2

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo"
   exit 1
fi

ORIG_USER=$SUDO_USER
if [ -z "$ORIG_USER" ]; then
    ORIG_USER=$(logname)
fi

# Base packages needed for all installation types
echo "Installing base system packages..."
sleep 2
pacman -Syu --noconfirm --needed base-devel git stow

# Set up AUR helper (paru) first - useful for all installation types
if ! command -v paru &> /dev/null; then
    echo "Installing paru AUR helper..."
    TMP_DIR=$(mktemp -d)
    chown $ORIG_USER: $TMP_DIR
    cd $TMP_DIR
    sudo -u $ORIG_USER git clone https://aur.archlinux.org/paru.git
    cd paru
    sudo -u $ORIG_USER makepkg -si --noconfirm
    cd ~
    rm -rf $TMP_DIR
fi
echo "Paru installed successfully."
sleep 2

# Function to install packages, trying pacman first, falling back to paru
install_packages() {
    local package_list=("$@")
    local failed_packages=()
    
    echo "Installing packages with pacman..."
    for pkg in "${package_list[@]}"; do
        if ! pacman -S --noconfirm --needed "$pkg" >/dev/null 2>&1; then
            failed_packages+=("$pkg")
        fi
    done
    
    if [ ${#failed_packages[@]} -gt 0 ]; then
        echo "Some packages couldn't be installed with pacman, trying with paru..."
        sudo -u $ORIG_USER paru -S --noconfirm --needed "${failed_packages[@]}"
    fi
}

# Define package arrays for different installation types
MINIMAL_PACKAGES=(
    # Core experience
    kitty                   # Terminal
    hyprland                # Window manager
    waybar                  # Status bar
    rofi-lbonn-wayland-git  # Application launcher (AUR)
    hyprpaper               # Wallpaper
    neovim                  # Text editor
    
    # Basic utilities
    btop                    # System monitor
    neofetch                # System info
    cava                    # Audio visualizer
    
    # Fonts
    ttf-jetbrains-mono-nerd # Primary font
    ttf-font-awesome        # Icon font
    noto-fonts              # General font
    noto-fonts-emoji        # Emoji support
    
    # Audio basics
    pipewire                # Audio system
    pipewire-pulse          # PulseAudio compatibility
    wireplumber             # Audio session manager
    
    # Bluetooth basics
    bluez                   # Bluetooth support
    bluez-utils             # Bluetooth utilities
    bluetui                 # Bluetooth terminal UI
    
    # Terminal fun
    pipes.sh                # Animated pipes (AUR)
    cbonsai                 # Terminal bonsai tree (AUR)
    asciiquarium            # Terminal aquarium (AUR)
)

USERLAND_PACKAGES=(
    # Productivity
    obsidian                # Note taking (AUR)
    
    # Browsers
    vivaldi                 # Browser (AUR)
    brave-browser           # Browser (AUR)
    
    # Development
    cursor                  # Code editor (AUR)
    
    # Communication
    discord                 # Chat application
    
    # Specialized
    # mathematica             # Math software (AUR)
	virtualbox
)

SYSTEM_PACKAGES=(
    ly                          # Display manager (AUR)
    xdg-desktop-portal-hyprland # Required for Hyprland
    
    # Utilities
    wl-clipboard
    
    # Audio extras
    pipewire-alsa 
    pipewire-jack
    pavucontrol                 # Audio control panel
    
    # Networking
    networkmanager              # Network management
    network-manager-applet      # Network system tray
    
    # Notifications
)

# Install packages based on selection
if [[ $INSTALL_TYPE == "minimal" || $INSTALL_TYPE == "userland" || $INSTALL_TYPE == "full" ]]; then
    echo "Installing minimal packages (required for dotfiles)..."
    install_packages "${MINIMAL_PACKAGES[@]}"
    
    # Enable Bluetooth service for all installation types
    echo "Enabling Bluetooth service..."
    systemctl enable bluetooth.service
fi

if [[ $INSTALL_TYPE == "userland" || $INSTALL_TYPE == "full" ]]; then
    echo "Installing userland packages (applications)..."
    install_packages "${USERLAND_PACKAGES[@]}"
fi

if [[ $INSTALL_TYPE == "full" ]]; then
    echo "Installing system packages (display manager, audio, etc.)..."
    install_packages "${SYSTEM_PACKAGES[@]}"
    
    # Enable additional system services for full install
    echo "Enabling NetworkManager service..."
    systemctl enable NetworkManager
    
    # Enable display manager
    echo "Enabling display manager (ly)..."
    systemctl enable ly.service
fi

# Oh-My-Zsh and ZSH plugins are useful for all installation types
echo "Installing Oh-My-Zsh for $ORIG_USER..."
sudo -u $ORIG_USER sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install powerlevel10k theme
echo "Installing Powerlevel10k theme..."
sudo -u $ORIG_USER git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/$ORIG_USER/.oh-my-zsh/custom/themes/powerlevel10k

# Install useful zsh plugins
echo "Installing Zsh plugins..."
sudo -u $ORIG_USER git clone https://github.com/zsh-users/zsh-autosuggestions /home/$ORIG_USER/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo -u $ORIG_USER git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$ORIG_USER/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Setup dotfiles
echo "Setting up dotfiles..."
DOTFILES_DIR="/home/$ORIG_USER/dotfiles"

# Backup existing configuration files if they exist
echo "Backing up any existing config files..."
BACKUP_DIR="/home/$ORIG_USER/.config.bak.$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Check if we're running from the dotfiles directory
if [[ -d "$DOTFILES_DIR/.git" && -f "$DOTFILES_DIR/.stow-local-ignore" ]]; then
    echo "Detected dotfiles repository at $DOTFILES_DIR"
    
    # Create list of directories to stow
    STOW_DIRS=()
    for dir in "$DOTFILES_DIR"/*/; do
        if [[ -d "$dir" && ! "$dir" =~ "\.git" && ! "$dir" =~ "scripts" ]]; then
            STOW_DIRS+=($(basename "$dir"))
        fi
    done
    
    # Backup existing config files if needed
    for dir in "${STOW_DIRS[@]}"; do
        CONFIG_DIR="/home/$ORIG_USER/.config/$(basename "$dir")"
        if [[ -d "$CONFIG_DIR" ]]; then
            echo "Backing up $CONFIG_DIR to $BACKUP_DIR/"
            cp -r "$CONFIG_DIR" "$BACKUP_DIR/"
        fi
    done
    
    # Use stow to create symlinks
echo "Using stow to force symlink creation by removing existing files..."
cd "$DOTFILES_DIR"

for dir in "${STOW_DIRS[@]}"; do
    echo "Processing $dir..."

    # Preview and remove conflicting files
    find "$dir" -type f | while read -r file; do
        target="/home/$ORIG_USER/${file#$dir/}"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "Removing conflicting file: $target"
            rm -f "$target"
        fi
    done

    # Now stow should work cleanly
    sudo -u "$ORIG_USER" stow -v "$dir" -t "/home/$ORIG_USER"
done
    
    echo "Dotfiles have been set up successfully!"
else
    echo "Dotfiles repository not detected at $DOTFILES_DIR"
    echo "Please set up your dotfiles manually with:"
    echo "  cd /path/to/your/dotfiles && stow */"
fi

sudo -u $ORIG_USER zsh -c "systemctl --user enable pipewire.service"
sudo -u $ORIG_USER zsh -c "systemctl --user enable pipewire-pulse.service"
sudo -u $ORIG_USER zsh -c "systemctl --user enable wireplumber.service"

sudo -u $ORIG_USER zsh -c "systemctl --user start pipewire.service"
sudo -u $ORIG_USER zsh -c "systemctl --user start pipewire-pulse.service"
sudo -u $ORIG_USER zsh -c "systemctl --user start wireplumber.service"

# Complete message with appropriate next steps
echo "Installation complete! Next steps:"

if [[ $INSTALL_TYPE == "minimal" ]]; then
    echo "1. The minimal environment has been installed."
    echo "2. Dotfiles have been set up automatically."
    echo "3. Start Hyprland manually: exec Hyprland"
elif [[ $INSTALL_TYPE == "userland" ]]; then
    echo "1. Userland applications have been installed."
    echo "2. Dotfiles have been set up automatically."
    echo "3. Start Hyprland manually: exec Hyprland"
    echo "4. Your browsers and applications are ready to use."
else
    echo "1. Full system has been installed."
    echo "2. Reboot your system to make sure all services start properly."
    echo "3. After reboot, log in through the ly display manager."
    echo "4. Dotfiles have been set up automatically."
fi

# Note: For waybar customizations
echo -e "\nNOTE: For waybar customizations, check out:"
echo "- mechabar on GitHub"
echo "- The following utilities have been installed: pipes.sh, cbonsai, asciiquarium"
