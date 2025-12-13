#!/bin/bash

# ========================================
# 🍚 Linux Dotfiles Installer 🥢
# ========================================
# Author: NajElaoud
# Description: Automated installer for my Linux dotfiles
# Repository: https://github.com/NajElaoud/Linux-Dotfiles
# ========================================

set -e  # Exit on error (unlike your productivity after installing this)

# ========================================
# Configuration
# ========================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Directories
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Installation modes
INSTALL_MODE="full"  # full, minimal, visual
DRY_RUN=false
SKIP_BACKUP=false
SKIP_JOKES=false
YOLO_MODE=false

# ========================================
# Error Handler
# ========================================

trap 'handle_error $? $LINENO' ERR

handle_error() {
    local exit_code=$1
    local line_number=$2
    print_error "Installation failed at line $line_number (exit code: $exit_code)"
    print_info "Check the error above for details"
    print_warning "Your backup is safe at: $BACKUP_DIR"
    exit $exit_code
}

# ========================================
# Helper Functions
# ========================================

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "=========================================="
    echo "  $1"
    echo "=========================================="
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗ ERROR:${NC} $1"
    if [[ "$SKIP_JOKES" == false ]]; then
        echo -e "${RED}   (Somewhere, a Windows user is laughing)${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING:${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_step() {
    echo -e "\n${MAGENTA}${BOLD}▶${NC} $1\n"
}

print_dry_run() {
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY RUN]${NC} $1"
    fi
}

# Easter egg function - randomly displays sarcastic messages
print_sarcasm() {
    if [[ "$SKIP_JOKES" == true ]]; then
        return
    fi
    
    local messages=(
        "Still reading the code? You could've been installing by now..."
        "Yes, I know this comment is unnecessary. So is your RGB keyboard, but here we are."
        "If you're checking for malicious code, props to you. If not... you should be."
        "This function does nothing. Like your New Year's resolutions."
        "// TODO: Remove this comment before committing (Narrator: They didn't)"
        "BTW I use Arch (this script works on other distros too tho)"
        "Roses are red, terminals are black, sudo rm -rf /, don't come back"
    )
    
    # 30% chance to display a message
    if [ $((RANDOM % 10)) -lt 3 ]; then
        echo -e "${MAGENTA}💭 ${messages[$((RANDOM % ${#messages[@]}))]}${NC}"
    fi
}

ask_yes_no() {
    if [[ "$YOLO_MODE" == true ]]; then
        print_warning "YOLO mode enabled - skipping confirmation"
        return 0
    fi
    
    while true; do
        read -p "$(echo -e ${CYAN}$1 \(y/n\):${NC} )" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no. (It's not that hard, I promise)";;
        esac
    done
}

# ========================================
# Detect Distribution
# ========================================

detect_distro() {
    print_step "Detecting your distribution..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_LIKE=$ID_LIKE
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO=$DISTRIB_ID
    else
        DISTRO="unknown"
        print_error "Could not detect distribution"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_warning "Congratulations, you're running an OS so obscure even this script gave up"
        fi
        exit 1
    fi
    
    # Normalize distro names
    case "$DISTRO" in
        ubuntu|debian|pop|linuxmint|elementary)
            PKG_MANAGER="apt"
            ;;
        arch|manjaro|endeavouros|garuda)
            PKG_MANAGER="pacman"
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "BTW, you use Arch? Of course you do."
            fi
            ;;
        fedora|rhel|centos)
            PKG_MANAGER="dnf"
            ;;
        opensuse*)
            PKG_MANAGER="zypper"
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "The most German package manager name in existence"
            fi
            ;;
        *)
            print_error "Unsupported distribution: $DISTRO"
            print_info "Please install packages manually"
            exit 1
            ;;
    esac
    
    print_success "Detected: $DISTRO (using $PKG_MANAGER)"
    print_sarcasm
}

# ========================================
# Check Dependencies
# ========================================

check_dependencies() {
    print_step "Checking existing dependencies..."
    
    local core_deps=(git curl wget zsh)
    local missing_core=()
    
    for dep in "${core_deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            print_success "$dep is installed"
        else
            missing_core+=("$dep")
            print_warning "$dep is NOT installed"
        fi
    done
    
    if [[ ${#missing_core[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_core[*]}"
        print_info "They will be installed in the next step"
    fi
}

# ========================================
# Install Packages
# ========================================

install_packages() {
    print_header "Installing Required Packages"
    
    if [[ "$INSTALL_MODE" == "minimal" ]]; then
        print_info "Minimal mode: Installing only essential packages"
    elif [[ "$SKIP_JOKES" == false ]]; then
        print_info "Fun fact: You're about to download more eye candy than actual productivity tools"
    fi
    
    case "$PKG_MANAGER" in
        apt)
            if [[ "$DRY_RUN" == false ]]; then
                print_info "Updating package list..."
                if [[ "$SKIP_JOKES" == false ]]; then
                    print_warning "(This is where Ubuntu users go make coffee)"
                fi
                sudo apt update
            else
                print_dry_run "Would run: sudo apt update"
            fi
            
            # Define package lists based on mode
            local CORE_PACKAGES=(
                "zsh"
                "git"
                "curl"
                "wget"
                "fontconfig"
                "python3"
                "python3-pip"
            )
            
            local VISUAL_PACKAGES=(
                "btop"
                "cava"
                "kitty"
                "htop"
                "cmatrix"
            )
            
            local FULL_PACKAGES=(
                "i3"
                "wofi"
                "gparted"
            )
            
            # Determine which packages to install
            local PACKAGES=("${CORE_PACKAGES[@]}")
            
            if [[ "$INSTALL_MODE" == "visual" ]] || [[ "$INSTALL_MODE" == "full" ]]; then
                PACKAGES+=("${VISUAL_PACKAGES[@]}")
            fi
            
            if [[ "$INSTALL_MODE" == "full" ]]; then
                PACKAGES+=("${FULL_PACKAGES[@]}")
            fi
            
            # Install packages
            for pkg in "${PACKAGES[@]}"; do
                if dpkg -l | grep -q "^ii  $pkg "; then
                    print_success "$pkg already installed"
                else
                    if [[ "$DRY_RUN" == false ]]; then
                        print_info "Installing $pkg..."
                        sudo apt install -y "$pkg" || print_warning "Failed to install $pkg"
                    else
                        print_dry_run "Would install: $pkg"
                    fi
                fi
            done
            
            # Install fastfetch from GitHub releases
            if ! command -v fastfetch &> /dev/null && [[ "$INSTALL_MODE" != "minimal" ]]; then
                if [[ "$DRY_RUN" == false ]]; then
                    print_info "Installing fastfetch..."
                    if [[ "$SKIP_JOKES" == false ]]; then
                        print_info "(neofetch died for this)"
                    fi
                    wget -q https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb -O /tmp/fastfetch.deb
                    sudo dpkg -i /tmp/fastfetch.deb
                    rm /tmp/fastfetch.deb
                else
                    print_dry_run "Would install: fastfetch"
                fi
            fi
            ;;
            
        pacman)
            if [[ "$DRY_RUN" == false ]]; then
                print_info "Updating package database..."
                sudo pacman -Sy
            else
                print_dry_run "Would run: sudo pacman -Sy"
            fi
            
            local CORE_PACKAGES=(
                "zsh"
                "git"
                "curl"
                "wget"
                "fontconfig"
                "python"
                "python-pip"
            )
            
            local VISUAL_PACKAGES=(
                "btop"
                "cava"
                "kitty"
                "htop"
                "cmatrix"
                "fastfetch"
            )
            
            local FULL_PACKAGES=(
                "i3-wm"
                "wofi"
                "gparted"
            )
            
            local PACKAGES=("${CORE_PACKAGES[@]}")
            
            if [[ "$INSTALL_MODE" == "visual" ]] || [[ "$INSTALL_MODE" == "full" ]]; then
                PACKAGES+=("${VISUAL_PACKAGES[@]}")
            fi
            
            if [[ "$INSTALL_MODE" == "full" ]]; then
                PACKAGES+=("${FULL_PACKAGES[@]}")
            fi
            
            for pkg in "${PACKAGES[@]}"; do
                if pacman -Q "$pkg" &> /dev/null; then
                    print_success "$pkg already installed"
                else
                    if [[ "$DRY_RUN" == false ]]; then
                        print_info "Installing $pkg..."
                        sudo pacman -S --noconfirm "$pkg" || print_warning "Failed to install $pkg"
                    else
                        print_dry_run "Would install: $pkg"
                    fi
                fi
            done
            ;;
            
        dnf)
            if [[ "$DRY_RUN" == false ]]; then
                print_info "Updating package metadata..."
                sudo dnf check-update || true
            else
                print_dry_run "Would run: sudo dnf check-update"
            fi
            
            local CORE_PACKAGES=(
                "zsh"
                "git"
                "curl"
                "wget"
                "fontconfig"
                "python3"
                "python3-pip"
            )
            
            local VISUAL_PACKAGES=(
                "btop"
                "cava"
                "kitty"
                "htop"
                "cmatrix"
            )
            
            local FULL_PACKAGES=(
                "i3"
                "wofi"
                "gparted"
            )
            
            local PACKAGES=("${CORE_PACKAGES[@]}")
            
            if [[ "$INSTALL_MODE" == "visual" ]] || [[ "$INSTALL_MODE" == "full" ]]; then
                PACKAGES+=("${VISUAL_PACKAGES[@]}")
            fi
            
            if [[ "$INSTALL_MODE" == "full" ]]; then
                PACKAGES+=("${FULL_PACKAGES[@]}")
            fi
            
            for pkg in "${PACKAGES[@]}"; do
                if rpm -q "$pkg" &> /dev/null; then
                    print_success "$pkg already installed"
                else
                    if [[ "$DRY_RUN" == false ]]; then
                        print_info "Installing $pkg..."
                        sudo dnf install -y "$pkg" || print_warning "Failed to install $pkg"
                    else
                        print_dry_run "Would install: $pkg"
                    fi
                fi
            done
            
            # Install fastfetch for dnf
            if ! command -v fastfetch &> /dev/null && [[ "$INSTALL_MODE" != "minimal" ]]; then
                if [[ "$DRY_RUN" == false ]]; then
                    print_info "Installing fastfetch..."
                    wget -q https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.rpm -O /tmp/fastfetch.rpm
                    sudo dnf install -y /tmp/fastfetch.rpm
                    rm /tmp/fastfetch.rpm
                else
                    print_dry_run "Would install: fastfetch"
                fi
            fi
            ;;
    esac
    
    # Install Python packages
    if [[ "$INSTALL_MODE" != "minimal" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing Python packages..."
            pip3 install --user pywal || print_warning "Failed to install pywal"
        else
            print_dry_run "Would install: pywal (Python package)"
        fi
    fi
    
    print_success "Package installation completed!"
    if [[ "$SKIP_JOKES" == false ]]; then
        print_info "Your terminal is now 69% cooler"
    fi
}

# ========================================
# Install Lazygit
# ========================================

install_lazygit() {
    if [[ "$INSTALL_MODE" == "minimal" ]]; then
        return
    fi
    
    print_header "Installing Lazygit"
    
    if command -v lazygit &> /dev/null; then
        print_success "Lazygit already installed"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "(For when you're too lazy to git gud)"
        fi
        return
    fi
    
    if [[ "$DRY_RUN" == false ]]; then
        print_info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp/ lazygit
        sudo install /tmp/lazygit /usr/local/bin
        rm /tmp/lazygit /tmp/lazygit.tar.gz
        print_success "Lazygit installed successfully!"
    else
        print_dry_run "Would install: lazygit"
    fi
}

# ========================================
# Install Lazydocker
# ========================================

install_lazydocker() {
    if [[ "$INSTALL_MODE" == "minimal" ]]; then
        return
    fi
    
    print_header "Installing Lazydocker"
    
    if command -v lazydocker &> /dev/null; then
        print_success "Lazydocker already installed"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "(Docker: Now with 20% less typing!)"
        fi
        return
    fi
    
    if [[ "$DRY_RUN" == false ]]; then
        print_info "Downloading lazydocker..."
        curl -s https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
        print_success "Lazydocker installed successfully!"
    else
        print_dry_run "Would install: lazydocker"
    fi
}

# ========================================
# Install Oh My Zsh
# ========================================

install_ohmyzsh() {
    print_header "Installing Oh My Zsh"
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh already installed"
    else
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing Oh My Zsh..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "Prepare for maximum terminal productivity (actual productivity may vary)"
            fi
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            print_success "Oh My Zsh installed!"
        else
            print_dry_run "Would install: Oh My Zsh"
        fi
    fi
    
    # Install zsh-autosuggestions
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing zsh-autosuggestions..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "(Because typing is hard)"
            fi
            git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        else
            print_dry_run "Would install: zsh-autosuggestions"
        fi
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing zsh-syntax-highlighting..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "(Pretty colors for your commands)"
            fi
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        else
            print_dry_run "Would install: zsh-syntax-highlighting"
        fi
    fi
    
    print_success "Oh My Zsh plugins installed!"
    if [[ "$SKIP_JOKES" == false ]]; then
        print_info "Your shell is now officially fancier than your life"
    fi
}

# ========================================
# Install Powerlevel10k
# ========================================

install_p10k() {
    print_header "Installing Powerlevel10k"
    
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        print_success "Powerlevel10k already installed"
    else
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing Powerlevel10k..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_warning "⚡ This theme has more power than your electricity bill"
            fi
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
            print_success "Powerlevel10k installed!"
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "Your prompt is about to look better than your resume"
            fi
        else
            print_dry_run "Would install: Powerlevel10k"
        fi
    fi
}

# ========================================
# Install Variety
# ========================================

install_variety() {
    if [[ "$INSTALL_MODE" == "minimal" ]]; then
        return
    fi
    
    print_header "Installing Variety"
    
    if command -v variety &> /dev/null; then
        print_success "Variety already installed"
        return
    fi
    
    if [[ "$DRY_RUN" == false ]]; then
        case "$PKG_MANAGER" in
            apt)
                sudo apt install -y variety
                ;;
            pacman)
                sudo pacman -S --noconfirm variety
                ;;
            dnf)
                sudo dnf install -y variety
                ;;
        esac
        print_success "Variety installed!"
    else
        print_dry_run "Would install: variety"
    fi
}

# ========================================
# Backup Existing Configs
# ========================================

backup_configs() {
    if [[ "$SKIP_BACKUP" == true ]]; then
        print_warning "Skipping backup as requested (YOLO!)"
        return
    fi
    
    print_header "Backing Up Existing Configurations"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_dry_run "Would create backup at: $BACKUP_DIR"
        return
    fi
    
    mkdir -p "$BACKUP_DIR"
    
    print_info "Creating backup at: $BACKUP_DIR"
    if [[ "$SKIP_JOKES" == false ]]; then
        print_warning "You know, just in case this script becomes sentient and goes rogue"
    fi
    
    FILES_TO_BACKUP=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.p10k.zsh"
        "$CONFIG_DIR/btop"
        "$CONFIG_DIR/cava"
        "$CONFIG_DIR/fastfetch"
        "$CONFIG_DIR/kitty"
        "$CONFIG_DIR/wal"
        "$CONFIG_DIR/wlogout"
        "$CONFIG_DIR/i3"
        "$CONFIG_DIR/wofi"
    )
    
    local backed_up=0
    for file in "${FILES_TO_BACKUP[@]}"; do
        if [ -e "$file" ]; then
            print_info "Backing up $file"
            cp -r "$file" "$BACKUP_DIR/" 2>/dev/null || true
            ((backed_up++))
        fi
    done
    
    if [[ $backed_up -gt 0 ]]; then
        print_success "Backed up $backed_up items"
        print_info "To restore: cp -r $BACKUP_DIR/* $HOME/"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_warning "(You'll probably never use it, but it's there)"
        fi
    else
        print_info "No existing configs to backup"
    fi
}

# ========================================
# Install Dotfiles
# ========================================

install_dotfiles() {
    print_header "Installing Dotfiles"
    
    # Create necessary directories
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$HOME/.local/share/fonts"
    mkdir -p "$HOME/.local/bin"
    
    # Install fonts
    print_info "Installing fonts..."
    if [[ "$SKIP_JOKES" == false ]]; then
        print_info "(So your terminal doesn't look like it's having a stroke)"
    fi
    
    if [ -d "$DOTFILES_DIR/.fonts" ]; then
        if [[ "$DRY_RUN" == false ]]; then
            cp -r "$DOTFILES_DIR/.fonts/"* "$HOME/.local/share/fonts/" 2>/dev/null || true
            if command -v fc-cache &> /dev/null; then
                fc-cache -fv > /dev/null 2>&1
                print_success "Fonts installed and cache updated!"
            else
                print_warning "fc-cache not found. Fonts copied but cache not updated"
            fi
        else
            print_dry_run "Would install fonts from: $DOTFILES_DIR/.fonts"
        fi
    fi
    
    # Symlink shell configs
    print_info "Symlinking shell configurations..."
    if [[ "$SKIP_JOKES" == false ]]; then
        print_warning "If you break something, remember: ctrl+z is your friend (oh wait, wrong program)"
    fi
    
    local shell_configs=(
        ".zshrc:$HOME/.zshrc"
        ".bashrc:$HOME/.bashrc"
        ".p10k.zsh:$HOME/.p10k.zsh"
    )
    
    for config in "${shell_configs[@]}"; do
        IFS=':' read -r src_file dst_file <<< "$config"
        local src="$DOTFILES_DIR/$src_file"
        
        if [ -e "$src" ]; then
            if [[ "$DRY_RUN" == false ]]; then
                # Remove old symlink/file if exists
                [ -L "$dst_file" ] || [ -f "$dst_file" ] && rm -f "$dst_file"
                ln -sf "$src" "$dst_file"
                print_success "Symlinked $src_file"
            else
                print_dry_run "Would symlink: $src -> $dst_file"
            fi
        fi
    done
    
    # Symlink config directories
    local config_dirs=("btop" "cava" "fastfetch" "kitty" "wal" "wlogout" "i3" "wofi")
    
    # Filter based on install mode
    if [[ "$INSTALL_MODE" == "minimal" ]]; then
        config_dirs=()  # Skip visual configs in minimal mode
    fi
    
    for dir in "${config_dirs[@]}"; do
        if [ -d "$DOTFILES_DIR/.config/$dir" ]; then
            if [[ "$DRY_RUN" == false ]]; then
                print_info "Symlinking $dir config..."
                rm -rf "$CONFIG_DIR/$dir"
                ln -sf "$DOTFILES_DIR/.config/$dir" "$CONFIG_DIR/$dir"
            else
                print_dry_run "Would symlink: $DOTFILES_DIR/.config/$dir -> $CONFIG_DIR/$dir"
            fi
        fi
    done
    
    # Copy wallpapers
    if [[ "$INSTALL_MODE" != "minimal" ]] && [ -d "$DOTFILES_DIR/Pictures" ]; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Copying wallpapers..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "(Because staring at default backgrounds is for normies)"
            fi
            mkdir -p "$HOME/Pictures/Wallpapers"
            cp -r "$DOTFILES_DIR/Pictures/"* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
        else
            print_dry_run "Would copy wallpapers to: $HOME/Pictures/Wallpapers"
        fi
    fi
    
    # Copy scripts
    if [ -d "$DOTFILES_DIR/.script" ]; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing scripts..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_warning "These scripts have more power than sudo. Use responsibly."
            fi
            cp -r "$DOTFILES_DIR/.script/"* "$HOME/.local/bin/" 2>/dev/null || true
            chmod +x "$HOME/.local/bin/"*.sh 2>/dev/null || true
            
            # Check if .local/bin is in PATH
            if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                print_warning "~/.local/bin is not in your PATH!"
                print_info "Add this to your shell config:"
                echo '  export PATH="$HOME/.local/bin:$PATH"'
            fi
        else
            print_dry_run "Would copy scripts to: $HOME/.local/bin"
        fi
    fi
    
    # Copy DDD config if exists
    if [ -d "$DOTFILES_DIR/.ddd" ]; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Copying DDD config..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "(For the 3 people who actually use DDD)"
            fi
            cp -r "$DOTFILES_DIR/.ddd" "$HOME/"
        else
            print_dry_run "Would copy: $DOTFILES_DIR/.ddd -> $HOME/.ddd"
        fi
    fi
    
    print_success "Dotfiles installed successfully!"
    if [[ "$SKIP_JOKES" == false ]]; then
        print_info "Congratulations! You're now 420% more likely to screenshot your terminal"
    fi
}

# ========================================
# Set Zsh as Default Shell
# ========================================
set_default_shell() {
    print_header "Setting Zsh as Default Shell"
    
    if [ "$SHELL" != "$(which zsh)" ]; then
        if ask_yes_no "Would you like to set zsh as your default shell?"; then
            if [[ "$DRY_RUN" == false ]]; then
                chsh -s "$(which zsh)"
                print_success "Zsh set as default shell (restart required)"
                if [[ "$SKIP_JOKES" == false ]]; then
                    print_info "bash users in shambles rn"
                fi
            else
                print_dry_run "Would change default shell to zsh"
            fi
        else
            print_info "Skipping shell change"
            if [[ "$SKIP_JOKES" == false ]]; then
                print_warning "Coward. (jk bash is fine... I guess)"
            fi
        fi
    else
        print_success "Zsh is already your default shell"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "A person of culture, I see"
        fi
    fi
}

# ========================================
# Optional Installations
# ========================================
install_optional() {
if [[ "$INSTALL_MODE" == "minimal" ]]; then
return
fi
print_header "Optional Installations"

if [[ "$SKIP_JOKES" == false ]]; then
    print_info "Time for the fun stuff (read: unnecessary bloat you absolutely need)"
fi

# BetterDiscord
if ask_yes_no "Install BetterDiscord?"; then
    if [[ "$DRY_RUN" == false ]]; then
        print_info "Installing BetterDiscord..."
        if [[ "$SKIP_JOKES" == false ]]; then
            print_warning "Discord ToS: ❌ | Cool themes: ✅"
        fi
        curl -O https://raw.githubusercontent.com/BetterDiscord/BetterDiscord/main/scripts/install.sh
        bash install.sh
        rm install.sh
        print_success "BetterDiscord installer run!"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "(Discord's legal team wants to know your location)"
        fi
    else
        print_dry_run "Would install: BetterDiscord"
    fi
fi

# Momoisay
if ask_yes_no "Install momoisay (cowsay alternative)?"; then
    if command -v go &> /dev/null; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing momoisay..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "Because cowsay is too mainstream"
            fi
            go install github.com/sudoblark/momoisay@latest
            print_success "Momoisay installed!"
        else
            print_dry_run "Would install: momoisay"
        fi
    else
        print_warning "Go is not installed. Skipping momoisay."
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "What are you, some kind of Python-only peasant?"
        fi
    fi
fi

# Wlogout
if ask_yes_no "Install wlogout?"; then
    if [[ "$DRY_RUN" == false ]]; then
        print_info "Installing fancy logout menu..."
        case "$PKG_MANAGER" in
            apt)
                sudo apt install -y wlogout
                ;;
            pacman)
                sudo pacman -S --noconfirm wlogout
                ;;
            dnf)
                sudo dnf install -y wlogout
                ;;
        esac
        print_success "Wlogout installed!"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "Now you can logout in S T Y L E ✨"
        fi
    else
        print_dry_run "Would install: wlogout"
    fi
fi
}

# ========================================
# Post Installation
# ========================================
post_install() {
print_header "Post Installation Setup"
# Apply pywal theme if wallpapers exist
if [[ "$INSTALL_MODE" != "minimal" ]] && [ -d "$HOME/Pictures/Wallpapers" ] && command -v wal &> /dev/null; then
    if [[ "$DRY_RUN" == false ]]; then
        print_info "Applying pywal theme..."
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "(Generating color schemes with SCIENCE)"
        fi
        WALLPAPER=$(find "$HOME/Pictures/Wallpapers" -type f | head -n 1)
        if [ -n "$WALLPAPER" ]; then
            wal -i "$WALLPAPER" > /dev/null 2>&1
            print_success "Pywal theme applied!"
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "Your terminal is now A E S T H E T I C"
            fi
        fi
    else
        print_dry_run "Would apply pywal theme"
    fi
fi

print_success "Installation completed!"
echo ""

if [[ "$SKIP_JOKES" == false ]]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  🎉 CONGRATULATIONS! 🎉                       ║${NC}"
    echo -e "${GREEN}║                                                ║${NC}"
    echo -e "${GREEN}║  You've successfully wasted... I mean         ║${NC}"
    echo -e "${GREEN}║  invested your time in terminal aesthetics!   ║${NC}"
    echo -e "${GREEN}║                                                ║${NC}"
    echo -e "${GREEN}║  Your productivity: 📉                        ║${NC}"
    echo -e "${GREEN}║  Your terminal's looks: 📈📈📈              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
else
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Installation Completed Successfully!   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
fi
echo ""

if [[ -d "$BACKUP_DIR" ]] && [[ "$SKIP_BACKUP" == false ]]; then
    print_info "Backup location: $BACKUP_DIR"
fi

print_warning "Please restart your terminal or run: source ~/.zshrc"
echo ""
print_info "Next steps:"
echo "  1. Restart your terminal (or run: exec zsh)"
echo "  2. Run: p10k configure"

if [[ "$INSTALL_MODE" != "minimal" ]]; then
    echo "  3. Try your helper scripts in ~/.local/bin"
fi

if [[ "$SKIP_JOKES" == false ]]; then
    echo "  4. Take 47 screenshots"
    echo "  5. Post on r/unixporn"
    echo "  6. Refuse to elaborate"
    echo "  7. Profit???"
fi

echo ""
print_success "May your terminal be forever aesthetic! ✨"

if [[ "$SKIP_JOKES" == false ]]; then
    echo ""
    print_info "P.S. - If something broke, that's a feature, not a bug 🐛"
fi
}
# ========================================
# Show Usage
# ========================================
show_usage() {
cat <<-EOF
        ╔════════════════════════════════════════════════════════════════╗
        ║                🍚 Linux Dotfiles Installer 🥢                  ║
        ╚════════════════════════════════════════════════════════════════╝
        Usage: ./install.sh [OPTIONS]
        Installation Modes:
        --full          Install everything (default)
        --minimal       Install only zsh + essential configs
        --visual        Install only visual apps (btop, cava, etc.)

        Options:
        --dry-run       Preview what would be installed without doing it
        --skip-backup   Skip backing up existing configs (DANGEROUS!)
        --skip-jokes    Remove all humor (why would you do this?)
        --yolo          Skip all confirmations (not recommended)
        -h, --help      Show this help message

        Easter Eggs:
        --hack-nasa     ¯_(ツ)_/¯

        Examples:
        ./install.sh                    # Full installation (recommended)
        ./install.sh --minimal          # Just the shell stuff
        ./install.sh --visual           # Just the eye candy
        ./install.sh --dry-run          # See what would happen
        ./install.sh --full --yolo      # FULL SEND (no confirmations)
        ./install.sh --skip-jokes       # Boring mode activated

        Installation Breakdown:
        MINIMAL:  zsh, oh-my-zsh, powerlevel10k, basic configs
        VISUAL:   + btop, cava, fastfetch, pywal, wallpapers
        FULL:     + lazygit, lazydocker, i3, wofi, everything!
        Repository: https://github.com/NajElaoud/Linux-Dotfiles
        Remember: With great rice comes great responsibility.
EOF
}

# ========================================
# Easter Eggs
# ========================================
if [ "$1" == "--hack-nasa" ]; then
        echo -e "${GREEN}Initiating NASA mainframe breach...${NC}
breach...
GREENInitiatingNASAmainframebreach...${NC}"
    echo ""
    for i in {1..100}; do
        echo -ne "GREEN█{GREEN}█
GREEN█{NC}"
        sleep 0.01
    done
    echo ""
    echo ""
    echo -e "CYANAccessgranted!{CYAN}Access granted!
CYANAccessgranted!{NC}"
    sleep 1
    echo -e "REDJustkidding.{RED}Just kidding.
REDJustkidding.{NC}"
    echo -e "YELLOWGotouchgrass.{YELLOW}Go touch grass.
YELLOWGotouchgrass.{NC}"
    echo ""
    exit 0
fi

# ========================================
# Parse Arguments
# ========================================
parse_args() {
while [[ $# -gt 0 ]]; do
case $1 in
--full)
INSTALL_MODE="full"
shift
;;
--minimal)
INSTALL_MODE="minimal"
shift
;;
--visual)
INSTALL_MODE="visual"
shift
;;
--dry-run)
DRY_RUN=true
shift
;;
--skip-backup)
SKIP_BACKUP=true
shift
;;
--skip-jokes)
SKIP_JOKES=true
shift
;;
--yolo)
YOLO_MODE=true
shift
;;
-h|--help)
show_usage
exit 0
;;
*)
print_error "Unknown option: $1"
echo ""
show_usage
exit 1
;;
esac
done
}
# ========================================
# Main Installation Flow
# ========================================
main() {
clear
# Print header
echo -e "${MAGENTA}${BOLD}"
cat <<-EOF
        ╔════════════════════════════════════════╗
        ║  🍚 Linux Dotfiles Installer 🥢      ║
        ╚════════════════════════════════════════╝
EOF

echo -e "${NC}"
if [[ "$SKIP_JOKES" == false ]]; then
    echo -e "${CYAN}Fun fact: You could've been productive by now.${NC}"
    echo -e "${CYAN}But no, you chose aesthetics. Respect. 🫡${NC}"
else
    echo -e "${CYAN}Professional installation mode activated.${NC}"
fi
echo ""

# Show what will happen
if [[ "$DRY_RUN" == true ]]; then
    print_warning "DRY RUN MODE - No changes will be made"
    echo ""
fi

print_info "Installation mode: $INSTALL_MODE"

if [[ "$INSTALL_MODE" == "minimal" ]]; then
    print_info "Installing: zsh, oh-my-zsh, powerlevel10k, basic configs"
elif [[ "$INSTALL_MODE" == "visual" ]]; then
    print_info "Installing: visual apps (btop, cava, etc.) + configs"
else
    print_info "Installing: EVERYTHING! (recommended)"
fi

echo ""
print_warning "This script will:"
echo "  • Install packages"
echo "  • Modify your configs"
echo "  • Symlink dotfiles"

if [[ "$SKIP_BACKUP" == false ]]; then
    echo "  • Create backup at: $BACKUP_DIR"
else
    echo "  • ${RED}Skip backups (YOLO mode!)${NC}"
fi

if [[ "$SKIP_JOKES" == false ]]; then
    echo "  • Consume approximately 69% of your free time"
fi

echo ""

if ! ask_yes_no "Ready to rice your system?"; then
    print_info "Installation cancelled."
    if [[ "$SKIP_JOKES" == false ]]; then
        print_warning "Fine. Go back to your vanilla terminal. See if I care."
    fi
    exit 0
fi

echo ""

# The point of no return...
print_info "🚀 Initiating rice sequence..."
if [[ "$SKIP_JOKES" == false ]]; then
    print_warning "There's no turning back now. This is your life now."
fi
sleep 1

# Run installation steps
detect_distro
check_dependencies
backup_configs
install_packages

if [[ "$INSTALL_MODE" != "minimal" ]]; then
    install_lazygit
    install_lazydocker
    install_variety
fi

install_ohmyzsh
install_p10k
install_dotfiles

if [[ "$INSTALL_MODE" == "full" ]]; then
    install_optional
fi

set_default_shell
post_install
}

# ========================================
# Entry Point
# ========================================
parse_args "$@"
main
#!/bin/bash

# ========================================
# 🍚 Linux Dotfiles Installer 🥢
# ========================================
# Author: NajElaoud
# Description: Automated installer for my Linux dotfiles
# Repository: https://github.com/NajElaoud/Linux-Dotfiles
# ========================================

set -e  # Exit on error (unlike your productivity after installing this)

# ========================================
# Configuration
# ========================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Directories
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Installation modes
INSTALL_MODE="full"  # full, minimal, visual
DRY_RUN=false
SKIP_BACKUP=false
SKIP_JOKES=false
YOLO_MODE=false

# ========================================
# Error Handler
# ========================================

trap 'handle_error $? $LINENO' ERR

handle_error() {
    local exit_code=$1
    local line_number=$2
    print_error "Installation failed at line $line_number (exit code: $exit_code)"
    print_info "Check the error above for details"
    print_warning "Your backup is safe at: $BACKUP_DIR"
    exit $exit_code
}

# ========================================
# Helper Functions
# ========================================

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "=========================================="
    echo "  $1"
    echo "=========================================="
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗ ERROR:${NC} $1"
    if [[ "$SKIP_JOKES" == false ]]; then
        echo -e "${RED}   (Somewhere, a Windows user is laughing)${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING:${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_step() {
    echo -e "\n${MAGENTA}${BOLD}▶${NC} $1\n"
}

print_dry_run() {
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY RUN]${NC} $1"
    fi
}

# Easter egg function - randomly displays sarcastic messages
print_sarcasm() {
    if [[ "$SKIP_JOKES" == true ]]; then
        return
    fi
    
    local messages=(
        "Still reading the code? You could've been installing by now..."
        "Yes, I know this comment is unnecessary. So is your RGB keyboard, but here we are."
        "If you're checking for malicious code, props to you. If not... you should be."
        "This function does nothing. Like your New Year's resolutions."
        "// TODO: Remove this comment before committing (Narrator: They didn't)"
        "BTW I use Arch (this script works on other distros too tho)"
        "Roses are red, terminals are black, sudo rm -rf /, don't come back"
    )
    
    # 30% chance to display a message
    if [ $((RANDOM % 10)) -lt 3 ]; then
        echo -e "${MAGENTA}💭 ${messages[$((RANDOM % ${#messages[@]}))]}${NC}"
    fi
}

ask_yes_no() {
    if [[ "$YOLO_MODE" == true ]]; then
        print_warning "YOLO mode enabled - skipping confirmation"
        return 0
    fi
    
    while true; do
        read -p "$(echo -e ${CYAN}$1 \(y/n\):${NC} )" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no. (It's not that hard, I promise)";;
        esac
    done
}

# ========================================
# Detect Distribution
# ========================================

detect_distro() {
    print_step "Detecting your distribution..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_LIKE=$ID_LIKE
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO=$DISTRIB_ID
    else
        DISTRO="unknown"
        print_error "Could not detect distribution"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_warning "Congratulations, you're running an OS so obscure even this script gave up"
        fi
        exit 1
    fi
    
    # Normalize distro names
    case "$DISTRO" in
        ubuntu|debian|pop|linuxmint|elementary)
            PKG_MANAGER="apt"
            ;;
        arch|manjaro|endeavouros|garuda)
            PKG_MANAGER="pacman"
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "BTW, you use Arch? Of course you do."
            fi
            ;;
        fedora|rhel|centos)
            PKG_MANAGER="dnf"
            ;;
        opensuse*)
            PKG_MANAGER="zypper"
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "The most German package manager name in existence"
            fi
            ;;
        *)
            print_error "Unsupported distribution: $DISTRO"
            print_info "Please install packages manually"
            exit 1
            ;;
    esac
    
    print_success "Detected: $DISTRO (using $PKG_MANAGER)"
    print_sarcasm
}

# ========================================
# Check Dependencies
# ========================================

check_dependencies() {
    print_step "Checking existing dependencies..."
    
    local core_deps=(git curl wget zsh)
    local missing_core=()
    
    for dep in "${core_deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            print_success "$dep is installed"
        else
            missing_core+=("$dep")
            print_warning "$dep is NOT installed"
        fi
    done
    
    if [[ ${#missing_core[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_core[*]}"
        print_info "They will be installed in the next step"
    fi
}

# ========================================
# Install Packages
# ========================================

install_packages() {
    print_header "Installing Required Packages"
    
    if [[ "$INSTALL_MODE" == "minimal" ]]; then
        print_info "Minimal mode: Installing only essential packages"
    elif [[ "$SKIP_JOKES" == false ]]; then
        print_info "Fun fact: You're about to download more eye candy than actual productivity tools"
    fi
    
    case "$PKG_MANAGER" in
        apt)
            if [[ "$DRY_RUN" == false ]]; then
                print_info "Updating package list..."
                if [[ "$SKIP_JOKES" == false ]]; then
                    print_warning "(This is where Ubuntu users go make coffee)"
                fi
                sudo apt update
            else
                print_dry_run "Would run: sudo apt update"
            fi
            
            # Define package lists based on mode
            local CORE_PACKAGES=(
                "zsh"
                "git"
                "curl"
                "wget"
                "fontconfig"
                "python3"
                "python3-pip"
            )
            
            local VISUAL_PACKAGES=(
                "btop"
                "cava"
                "kitty"
                "htop"
                "cmatrix"
            )
            
            local FULL_PACKAGES=(
                "i3"
                "wofi"
                "gparted"
            )
            
            # Determine which packages to install
            local PACKAGES=("${CORE_PACKAGES[@]}")
            
            if [[ "$INSTALL_MODE" == "visual" ]] || [[ "$INSTALL_MODE" == "full" ]]; then
                PACKAGES+=("${VISUAL_PACKAGES[@]}")
            fi
            
            if [[ "$INSTALL_MODE" == "full" ]]; then
                PACKAGES+=("${FULL_PACKAGES[@]}")
            fi
            
            # Install packages
            for pkg in "${PACKAGES[@]}"; do
                if dpkg -l | grep -q "^ii  $pkg "; then
                    print_success "$pkg already installed"
                else
                    if [[ "$DRY_RUN" == false ]]; then
                        print_info "Installing $pkg..."
                        sudo apt install -y "$pkg" || print_warning "Failed to install $pkg"
                    else
                        print_dry_run "Would install: $pkg"
                    fi
                fi
            done
            
            # Install fastfetch from GitHub releases
            if ! command -v fastfetch &> /dev/null && [[ "$INSTALL_MODE" != "minimal" ]]; then
                if [[ "$DRY_RUN" == false ]]; then
                    print_info "Installing fastfetch..."
                    if [[ "$SKIP_JOKES" == false ]]; then
                        print_info "(neofetch died for this)"
                    fi
                    wget -q https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb -O /tmp/fastfetch.deb
                    sudo dpkg -i /tmp/fastfetch.deb
                    rm /tmp/fastfetch.deb
                else
                    print_dry_run "Would install: fastfetch"
                fi
            fi
            ;;
            
        pacman)
            if [[ "$DRY_RUN" == false ]]; then
                print_info "Updating package database..."
                sudo pacman -Sy
            else
                print_dry_run "Would run: sudo pacman -Sy"
            fi
            
            local CORE_PACKAGES=(
                "zsh"
                "git"
                "curl"
                "wget"
                "fontconfig"
                "python"
                "python-pip"
            )
            
            local VISUAL_PACKAGES=(
                "btop"
                "cava"
                "kitty"
                "htop"
                "cmatrix"
                "fastfetch"
            )
            
            local FULL_PACKAGES=(
                "i3-wm"
                "wofi"
                "gparted"
            )
            
            local PACKAGES=("${CORE_PACKAGES[@]}")
            
            if [[ "$INSTALL_MODE" == "visual" ]] || [[ "$INSTALL_MODE" == "full" ]]; then
                PACKAGES+=("${VISUAL_PACKAGES[@]}")
            fi
            
            if [[ "$INSTALL_MODE" == "full" ]]; then
                PACKAGES+=("${FULL_PACKAGES[@]}")
            fi
            
            for pkg in "${PACKAGES[@]}"; do
                if pacman -Q "$pkg" &> /dev/null; then
                    print_success "$pkg already installed"
                else
                    if [[ "$DRY_RUN" == false ]]; then
                        print_info "Installing $pkg..."
                        sudo pacman -S --noconfirm "$pkg" || print_warning "Failed to install $pkg"
                    else
                        print_dry_run "Would install: $pkg"
                    fi
                fi
            done
            ;;
            
        dnf)
            if [[ "$DRY_RUN" == false ]]; then
                print_info "Updating package metadata..."
                sudo dnf check-update || true
            else
                print_dry_run "Would run: sudo dnf check-update"
            fi
            
            local CORE_PACKAGES=(
                "zsh"
                "git"
                "curl"
                "wget"
                "fontconfig"
                "python3"
                "python3-pip"
            )
            
            local VISUAL_PACKAGES=(
                "btop"
                "cava"
                "kitty"
                "htop"
                "cmatrix"
            )
            
            local FULL_PACKAGES=(
                "i3"
                "wofi"
                "gparted"
            )
            
            local PACKAGES=("${CORE_PACKAGES[@]}")
            
            if [[ "$INSTALL_MODE" == "visual" ]] || [[ "$INSTALL_MODE" == "full" ]]; then
                PACKAGES+=("${VISUAL_PACKAGES[@]}")
            fi
            
            if [[ "$INSTALL_MODE" == "full" ]]; then
                PACKAGES+=("${FULL_PACKAGES[@]}")
            fi
            
            for pkg in "${PACKAGES[@]}"; do
                if rpm -q "$pkg" &> /dev/null; then
                    print_success "$pkg already installed"
                else
                    if [[ "$DRY_RUN" == false ]]; then
                        print_info "Installing $pkg..."
                        sudo dnf install -y "$pkg" || print_warning "Failed to install $pkg"
                    else
                        print_dry_run "Would install: $pkg"
                    fi
                fi
            done
            
            # Install fastfetch for dnf
            if ! command -v fastfetch &> /dev/null && [[ "$INSTALL_MODE" != "minimal" ]]; then
                if [[ "$DRY_RUN" == false ]]; then
                    print_info "Installing fastfetch..."
                    wget -q https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.rpm -O /tmp/fastfetch.rpm
                    sudo dnf install -y /tmp/fastfetch.rpm
                    rm /tmp/fastfetch.rpm
                else
                    print_dry_run "Would install: fastfetch"
                fi
            fi
            ;;
    esac
    
    # Install Python packages
    if [[ "$INSTALL_MODE" != "minimal" ]]; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing Python packages..."
            pip3 install --user pywal || print_warning "Failed to install pywal"
        else
            print_dry_run "Would install: pywal (Python package)"
        fi
    fi
    
    print_success "Package installation completed!"
    if [[ "$SKIP_JOKES" == false ]]; then
        print_info "Your terminal is now 69% cooler"
    fi
}

# ========================================
# Install Lazygit
# ========================================

install_lazygit() {
    if [[ "$INSTALL_MODE" == "minimal" ]]; then
        return
    fi
    
    print_header "Installing Lazygit"
    
    if command -v lazygit &> /dev/null; then
        print_success "Lazygit already installed"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "(For when you're too lazy to git gud)"
        fi
        return
    fi
    
    if [[ "$DRY_RUN" == false ]]; then
        print_info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp/ lazygit
        sudo install /tmp/lazygit /usr/local/bin
        rm /tmp/lazygit /tmp/lazygit.tar.gz
        print_success "Lazygit installed successfully!"
    else
        print_dry_run "Would install: lazygit"
    fi
}

# ========================================
# Install Lazydocker
# ========================================

install_lazydocker() {
    if [[ "$INSTALL_MODE" == "minimal" ]]; then
        return
    fi
    
    print_header "Installing Lazydocker"
    
    if command -v lazydocker &> /dev/null; then
        print_success "Lazydocker already installed"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "(Docker: Now with 20% less typing!)"
        fi
        return
    fi
    
    if [[ "$DRY_RUN" == false ]]; then
        print_info "Downloading lazydocker..."
        curl -s https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
        print_success "Lazydocker installed successfully!"
    else
        print_dry_run "Would install: lazydocker"
    fi
}

# ========================================
# Install Oh My Zsh
# ========================================

install_ohmyzsh() {
    print_header "Installing Oh My Zsh"
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh already installed"
    else
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing Oh My Zsh..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "Prepare for maximum terminal productivity (actual productivity may vary)"
            fi
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            print_success "Oh My Zsh installed!"
        else
            print_dry_run "Would install: Oh My Zsh"
        fi
    fi
    
    # Install zsh-autosuggestions
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing zsh-autosuggestions..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "(Because typing is hard)"
            fi
            git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        else
            print_dry_run "Would install: zsh-autosuggestions"
        fi
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing zsh-syntax-highlighting..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "(Pretty colors for your commands)"
            fi
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        else
            print_dry_run "Would install: zsh-syntax-highlighting"
        fi
    fi
    
    print_success "Oh My Zsh plugins installed!"
    if [[ "$SKIP_JOKES" == false ]]; then
        print_info "Your shell is now officially fancier than your life"
    fi
}

# ========================================
# Install Powerlevel10k
# ========================================

install_p10k() {
    print_header "Installing Powerlevel10k"
    
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        print_success "Powerlevel10k already installed"
    else
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing Powerlevel10k..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_warning "⚡ This theme has more power than your electricity bill"
            fi
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
            print_success "Powerlevel10k installed!"
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "Your prompt is about to look better than your resume"
            fi
        else
            print_dry_run "Would install: Powerlevel10k"
        fi
    fi
}

# ========================================
# Install Variety
# ========================================

install_variety() {
    if [[ "$INSTALL_MODE" == "minimal" ]]; then
        return
    fi
    
    print_header "Installing Variety"
    
    if command -v variety &> /dev/null; then
        print_success "Variety already installed"
        return
    fi
    
    if [[ "$DRY_RUN" == false ]]; then
        case "$PKG_MANAGER" in
            apt)
                sudo apt install -y variety
                ;;
            pacman)
                sudo pacman -S --noconfirm variety
                ;;
            dnf)
                sudo dnf install -y variety
                ;;
        esac
        print_success "Variety installed!"
    else
        print_dry_run "Would install: variety"
    fi
}

# ========================================
# Backup Existing Configs
# ========================================

backup_configs() {
    if [[ "$SKIP_BACKUP" == true ]]; then
        print_warning "Skipping backup as requested (YOLO!)"
        return
    fi
    
    print_header "Backing Up Existing Configurations"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_dry_run "Would create backup at: $BACKUP_DIR"
        return
    fi
    
    mkdir -p "$BACKUP_DIR"
    
    print_info "Creating backup at: $BACKUP_DIR"
    if [[ "$SKIP_JOKES" == false ]]; then
        print_warning "You know, just in case this script becomes sentient and goes rogue"
    fi
    
    FILES_TO_BACKUP=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.p10k.zsh"
        "$CONFIG_DIR/btop"
        "$CONFIG_DIR/cava"
        "$CONFIG_DIR/fastfetch"
        "$CONFIG_DIR/kitty"
        "$CONFIG_DIR/wal"
        "$CONFIG_DIR/wlogout"
        "$CONFIG_DIR/i3"
        "$CONFIG_DIR/wofi"
    )
    
    local backed_up=0
    for file in "${FILES_TO_BACKUP[@]}"; do
        if [ -e "$file" ]; then
            print_info "Backing up $file"
            cp -r "$file" "$BACKUP_DIR/" 2>/dev/null || true
            ((backed_up++))
        fi
    done
    
    if [[ $backed_up -gt 0 ]]; then
        print_success "Backed up $backed_up items"
        print_info "To restore: cp -r $BACKUP_DIR/* $HOME/"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_warning "(You'll probably never use it, but it's there)"
        fi
    else
        print_info "No existing configs to backup"
    fi
}

# ========================================
# Install Dotfiles
# ========================================

install_dotfiles() {
    print_header "Installing Dotfiles"
    
    # Create necessary directories
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$HOME/.local/share/fonts"
    mkdir -p "$HOME/.local/bin"
    
    # Install fonts
    print_info "Installing fonts..."
    if [[ "$SKIP_JOKES" == false ]]; then
        print_info "(So your terminal doesn't look like it's having a stroke)"
    fi
    
    if [ -d "$DOTFILES_DIR/.fonts" ]; then
        if [[ "$DRY_RUN" == false ]]; then
            cp -r "$DOTFILES_DIR/.fonts/"* "$HOME/.local/share/fonts/" 2>/dev/null || true
            if command -v fc-cache &> /dev/null; then
                fc-cache -fv > /dev/null 2>&1
                print_success "Fonts installed and cache updated!"
            else
                print_warning "fc-cache not found. Fonts copied but cache not updated"
            fi
        else
            print_dry_run "Would install fonts from: $DOTFILES_DIR/.fonts"
        fi
    fi
    
    # Symlink shell configs
    print_info "Symlinking shell configurations..."
    if [[ "$SKIP_JOKES" == false ]]; then
        print_warning "If you break something, remember: ctrl+z is your friend (oh wait, wrong program)"
    fi
    
    local shell_configs=(
        ".zshrc:$HOME/.zshrc"
        ".bashrc:$HOME/.bashrc"
        ".p10k.zsh:$HOME/.p10k.zsh"
    )
    
    for config in "${shell_configs[@]}"; do
        IFS=':' read -r src_file dst_file <<< "$config"
        local src="$DOTFILES_DIR/$src_file"
        
        if [ -e "$src" ]; then
            if [[ "$DRY_RUN" == false ]]; then
                # Remove old symlink/file if exists
                [ -L "$dst_file" ] || [ -f "$dst_file" ] && rm -f "$dst_file"
                ln -sf "$src" "$dst_file"
                print_success "Symlinked $src_file"
            else
                print_dry_run "Would symlink: $src -> $dst_file"
            fi
        fi
    done
    
    # Symlink config directories
    local config_dirs=("btop" "cava" "fastfetch" "kitty" "wal" "wlogout" "i3" "wofi")
    
    # Filter based on install mode
    if [[ "$INSTALL_MODE" == "minimal" ]]; then
        config_dirs=()  # Skip visual configs in minimal mode
    fi
    
    for dir in "${config_dirs[@]}"; do
        if [ -d "$DOTFILES_DIR/.config/$dir" ]; then
            if [[ "$DRY_RUN" == false ]]; then
                print_info "Symlinking $dir config..."
                rm -rf "$CONFIG_DIR/$dir"
                ln -sf "$DOTFILES_DIR/.config/$dir" "$CONFIG_DIR/$dir"
            else
                print_dry_run "Would symlink: $DOTFILES_DIR/.config/$dir -> $CONFIG_DIR/$dir"
            fi
        fi
    done
    
    # Copy wallpapers
    if [[ "$INSTALL_MODE" != "minimal" ]] && [ -d "$DOTFILES_DIR/Pictures" ]; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Copying wallpapers..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "(Because staring at default backgrounds is for normies)"
            fi
            mkdir -p "$HOME/Pictures/Wallpapers"
            cp -r "$DOTFILES_DIR/Pictures/"* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
        else
            print_dry_run "Would copy wallpapers to: $HOME/Pictures/Wallpapers"
        fi
    fi
    
    # Copy scripts
    if [ -d "$DOTFILES_DIR/.script" ]; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing scripts..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_warning "These scripts have more power than sudo. Use responsibly."
            fi
            cp -r "$DOTFILES_DIR/.script/"* "$HOME/.local/bin/" 2>/dev/null || true
            chmod +x "$HOME/.local/bin/"*.sh 2>/dev/null || true
            
            # Check if .local/bin is in PATH
            if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                print_warning "~/.local/bin is not in your PATH!"
                print_info "Add this to your shell config:"
                echo '  export PATH="$HOME/.local/bin:$PATH"'
            fi
        else
            print_dry_run "Would copy scripts to: $HOME/.local/bin"
        fi
    fi
    
    # Copy DDD config if exists
    if [ -d "$DOTFILES_DIR/.ddd" ]; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Copying DDD config..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "(For the 3 people who actually use DDD)"
            fi
            cp -r "$DOTFILES_DIR/.ddd" "$HOME/"
        else
            print_dry_run "Would copy: $DOTFILES_DIR/.ddd -> $HOME/.ddd"
        fi
    fi
    
    print_success "Dotfiles installed successfully!"
    if [[ "$SKIP_JOKES" == false ]]; then
        print_info "Congratulations! You're now 420% more likely to screenshot your terminal"
    fi
}

# ========================================
# Set Zsh as Default Shell
# ========================================
set_default_shell() {
    print_header "Setting Zsh as Default Shell"
    
    if [ "$SHELL" != "$(which zsh)" ]; then
        if ask_yes_no "Would you like to set zsh as your default shell?"; then
            if [[ "$DRY_RUN" == false ]]; then
                chsh -s "$(which zsh)"
                print_success "Zsh set as default shell (restart required)"
                if [[ "$SKIP_JOKES" == false ]]; then
                    print_info "bash users in shambles rn"
                fi
            else
                print_dry_run "Would change default shell to zsh"
            fi
        else
            print_info "Skipping shell change"
            if [[ "$SKIP_JOKES" == false ]]; then
                print_warning "Coward. (jk bash is fine... I guess)"
            fi
        fi
    else
        print_success "Zsh is already your default shell"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "A person of culture, I see"
        fi
    fi
}

========================================
Optional Installations
========================================
install_optional() {
if [[ "$INSTALL_MODE" == "minimal" ]]; then
return
fi
print_header "Optional Installations"

if [[ "$SKIP_JOKES" == false ]]; then
    print_info "Time for the fun stuff (read: unnecessary bloat you absolutely need)"
fi

# BetterDiscord
if ask_yes_no "Install BetterDiscord?"; then
    if [[ "$DRY_RUN" == false ]]; then
        print_info "Installing BetterDiscord..."
        if [[ "$SKIP_JOKES" == false ]]; then
            print_warning "Discord ToS: ❌ | Cool themes: ✅"
        fi
        curl -O https://raw.githubusercontent.com/BetterDiscord/BetterDiscord/main/scripts/install.sh
        bash install.sh
        rm install.sh
        print_success "BetterDiscord installer run!"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "(Discord's legal team wants to know your location)"
        fi
    else
        print_dry_run "Would install: BetterDiscord"
    fi
fi

# Momoisay
if ask_yes_no "Install momoisay (cowsay alternative)?"; then
    if command -v go &> /dev/null; then
        if [[ "$DRY_RUN" == false ]]; then
            print_info "Installing momoisay..."
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "Because cowsay is too mainstream"
            fi
            go install github.com/sudoblark/momoisay@latest
            print_success "Momoisay installed!"
        else
            print_dry_run "Would install: momoisay"
        fi
    else
        print_warning "Go is not installed. Skipping momoisay."
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "What are you, some kind of Python-only peasant?"
        fi
    fi
fi

# Wlogout
if ask_yes_no "Install wlogout?"; then
    if [[ "$DRY_RUN" == false ]]; then
        print_info "Installing fancy logout menu..."
        case "$PKG_MANAGER" in
            apt)
                sudo apt install -y wlogout
                ;;
            pacman)
                sudo pacman -S --noconfirm wlogout
                ;;
            dnf)
                sudo dnf install -y wlogout
                ;;
        esac
        print_success "Wlogout installed!"
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "Now you can logout in S T Y L E ✨"
        fi
    else
        print_dry_run "Would install: wlogout"
    fi
fi
}

========================================
Post Installation
========================================
post_install() {
print_header "Post Installation Setup"
# Apply pywal theme if wallpapers exist
if [[ "$INSTALL_MODE" != "minimal" ]] && [ -d "$HOME/Pictures/Wallpapers" ] && command -v wal &> /dev/null; then
    if [[ "$DRY_RUN" == false ]]; then
        print_info "Applying pywal theme..."
        if [[ "$SKIP_JOKES" == false ]]; then
            print_info "(Generating color schemes with SCIENCE)"
        fi
        WALLPAPER=$(find "$HOME/Pictures/Wallpapers" -type f | head -n 1)
        if [ -n "$WALLPAPER" ]; then
            wal -i "$WALLPAPER" > /dev/null 2>&1
            print_success "Pywal theme applied!"
            if [[ "$SKIP_JOKES" == false ]]; then
                print_info "Your terminal is now A E S T H E T I C"
            fi
        fi
    else
        print_dry_run "Would apply pywal theme"
    fi
fi

print_success "Installation completed!"
echo ""

if [[ "$SKIP_JOKES" == false ]]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  🎉 CONGRATULATIONS! 🎉                       ║${NC}"
    echo -e "${GREEN}║                                                ║${NC}"
    echo -e "${GREEN}║  You've successfully wasted... I mean         ║${NC}"
    echo -e "${GREEN}║  invested your time in terminal aesthetics!   ║${NC}"
    echo -e "${GREEN}║                                                ║${NC}"
    echo -e "${GREEN}║  Your productivity: 📉                        ║${NC}"
    echo -e "${GREEN}║  Your terminal's looks: 📈📈📈              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
else
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Installation Completed Successfully!   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
fi
echo ""

if [[ -d "$BACKUP_DIR" ]] && [[ "$SKIP_BACKUP" == false ]]; then
    print_info "Backup location: $BACKUP_DIR"
fi

print_warning "Please restart your terminal or run: source ~/.zshrc"
echo ""
print_info "Next steps:"
echo "  1. Restart your terminal (or run: exec zsh)"
echo "  2. Run: p10k configure"

if [[ "$INSTALL_MODE" != "minimal" ]]; then
    echo "  3. Try your helper scripts in ~/.local/bin"
fi

if [[ "$SKIP_JOKES" == false ]]; then
    echo "  4. Take 47 screenshots"
    echo "  5. Post on r/unixporn"
    echo "  6. Refuse to elaborate"
    echo "  7. Profit???"
fi

echo ""
print_success "May your terminal be forever aesthetic! ✨"

if [[ "$SKIP_JOKES" == false ]]; then
    echo ""
    print_info "P.S. - If something broke, that's a feature, not a bug 🐛"
fi
}
========================================
Show Usage
========================================
show_usage() {
cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                🍚 Linux Dotfiles Installer 🥢                 ║
╚════════════════════════════════════════════════════════════════╝
Usage: ./install.sh [OPTIONS]
Installation Modes:
--full          Install everything (default)
--minimal       Install only zsh + essential configs
--visual        Install only visual apps (btop, cava, etc.)
Options:
--dry-run       Preview what would be installed without doing it
--skip-backup   Skip backing up existing configs (DANGEROUS!)
--skip-jokes    Remove all humor (why would you do this?)
--yolo          Skip all confirmations (not recommended)
-h, --help      Show this help message
Easter Eggs:
--hack-nasa     ¯_(ツ)_/¯
Examples:
./install.sh                    # Full installation (recommended)
./install.sh --minimal          # Just the shell stuff
./install.sh --visual           # Just the eye candy
./install.sh --dry-run          # See what would happen
./install.sh --full --yolo      # FULL SEND (no confirmations)
./install.sh --skip-jokes       # Boring mode activated
Installation Breakdown:
MINIMAL:  zsh, oh-my-zsh, powerlevel10k, basic configs
VISUAL:   + btop, cava, fastfetch, pywal, wallpapers
FULL:     + lazygit, lazydocker, i3, wofi, everything!
Repository: https://github.com/NajElaoud/Linux-Dotfiles
Remember: With great rice comes great responsibility.
EOF
}
========================================
Easter Eggs
========================================
if [ "$1" == "--hack-nasa" ]; then
    echo -e "GREENInitiatingNASAmainframebreach...{GREEN}Initiating NASA mainframe breach...
GREENInitiatingNASAmainframebreach...{NC}"
    echo ""
    for i in {1..100}; do
        echo -ne "GREEN█{GREEN}█
GREEN█{NC}"
        sleep 0.01
    done
    echo ""
    echo ""
    echo -e "CYANAccessgranted!{CYAN}Access granted!
CYANAccessgranted!{NC}"
    sleep 1
    echo -e "REDJustkidding.{RED}Just kidding.
REDJustkidding.{NC}"
    echo -e "YELLOWGotouchgrass.{YELLOW}Go touch grass.
YELLOWGotouchgrass.{NC}"
    echo ""
    exit 0
fi

========================================
Parse Arguments
========================================
parse_args() {
while [[ $# -gt 0 ]]; do
case $1 in
--full)
INSTALL_MODE="full"
shift
;;
--minimal)
INSTALL_MODE="minimal"
shift
;;
--visual)
INSTALL_MODE="visual"
shift
;;
--dry-run)
DRY_RUN=true
shift
;;
--skip-backup)
SKIP_BACKUP=true
shift
;;
--skip-jokes)
SKIP_JOKES=true
shift
;;
--yolo)
YOLO_MODE=true
shift
;;
-h|--help)
show_usage
exit 0
;;
*)
print_error "Unknown option: $1"
echo ""
show_usage
exit 1
;;
esac
done
}
========================================
Main Installation Flow
========================================
main() {
clear
# Print header
echo -e "${MAGENTA}${BOLD}"
cat << "EOF"
╔════════════════════════════════════════╗
║  🍚 Linux Dotfiles Installer 🥢      ║
╚════════════════════════════════════════╝

EOF
echo -e "${NC}"
if [[ "$SKIP_JOKES" == false ]]; then
    echo -e "${CYAN}Fun fact: You could've been productive by now.${NC}"
    echo -e "${CYAN}But no, you chose aesthetics. Respect. 🫡${NC}"
else
    echo -e "${CYAN}Professional installation mode activated.${NC}"
fi
echo ""

# Show what will happen
if [[ "$DRY_RUN" == true ]]; then
    print_warning "DRY RUN MODE - No changes will be made"
    echo ""
fi

print_info "Installation mode: $INSTALL_MODE"

if [[ "$INSTALL_MODE" == "minimal" ]]; then
    print_info "Installing: zsh, oh-my-zsh, powerlevel10k, basic configs"
elif [[ "$INSTALL_MODE" == "visual" ]]; then
    print_info "Installing: visual apps (btop, cava, etc.) + configs"
else
    print_info "Installing: EVERYTHING! (recommended)"
fi

echo ""
print_warning "This script will:"
echo "  • Install packages"
echo "  • Modify your configs"
echo "  • Symlink dotfiles"

if [[ "$SKIP_BACKUP" == false ]]; then
    echo "  • Create backup at: $BACKUP_DIR"
else
    echo "  • ${RED}Skip backups (YOLO mode!)${NC}"
fi

if [[ "$SKIP_JOKES" == false ]]; then
    echo "  • Consume approximately 69% of your free time"
fi

echo ""

if ! ask_yes_no "Ready to rice your system?"; then
    print_info "Installation cancelled."
    if [[ "$SKIP_JOKES" == false ]]; then
        print_warning "Fine. Go back to your vanilla terminal. See if I care."
    fi
    exit 0
fi

echo ""

# The point of no return...
print_info "🚀 Initiating rice sequence..."
if [[ "$SKIP_JOKES" == false ]]; then
    print_warning "There's no turning back now. This is your life now."
fi
sleep 1

# Run installation steps
detect_distro
check_dependencies
backup_configs
install_packages

if [[ "$INSTALL_MODE" != "minimal" ]]; then
    install_lazygit
    install_lazydocker
    install_variety
fi

install_ohmyzsh
install_p10k
install_dotfiles

if [[ "$INSTALL_MODE" == "full" ]]; then
    install_optional
fi

set_default_shell
post_install
}
========================================
Entry Point
========================================
parse_args "$@"
main</parameter>
