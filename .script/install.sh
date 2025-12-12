#!/bin/bash

# ========================================
# 🍚 Linux Dotfiles Installer 🥢
# ========================================
# Author: NajElaoud
# Description: Automated installer for my Linux dotfiles
# Repository: https://github.com/NajElaoud/Linux-Dotfiles
# 
# WARNING: This script may cause:
# - Uncontrollable urge to rice everything
# - Terminal addiction
# - Inability to use vanilla configs ever again
# - Sudden hatred for default themes
# - 3 AM configuration sessions
# ========================================

set -e  # Exit on error (unlike your productivity after installing this)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Directories
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# ========================================
# Helper Functions
# ========================================

print_header() {
    echo -e "${CYAN}"
    echo "=========================================="
    echo "  $1"
    echo "=========================================="
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    echo -e "${RED}   (Somewhere, a Windows user is laughing)${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Easter egg function - randomly displays sarcastic messages
print_sarcasm() {
    local messages=(
        "Still reading the code? You could've been installing by now..."
        "Yes, I know this comment is unnecessary. So is your RGB keyboard, but here we are."
        "If you're checking for malicious code, props to you. If not... you should be."
        "This function does nothing. Like your New Year's resolutions."
        "// TODO: Remove this comment before committing (Narrator: They didn't)"
        "Ah yes, reading bash scripts at 2 AM. A person of culture."
        "If you understand this script, you're overqualified for Stack Overflow."
    )
    
    # 30% chance to display a message (if you even reach this function)
    if [ $((RANDOM % 10)) -lt 3 ]; then
        echo -e "${MAGENTA}💭 ${messages[$((RANDOM % ${#messages[@]}))]}${NC}"
    fi
}

ask_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
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
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_LIKE=$ID_LIKE
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO=$DISTRIB_ID
    else
        DISTRO="unknown"
        # Congratulations, you're running an OS so obscure even this script gave up
    fi
    
    # Normalize distro names
    case "$DISTRO" in
        ubuntu|debian|pop|linuxmint|elementary)
            PKG_MANAGER="apt"
            ;;
        arch|manjaro|endeavouros|garuda)
            PKG_MANAGER="pacman"
            # BTW, you use Arch? Of course you do.
            ;;
        fedora|rhel|centos)
            PKG_MANAGER="dnf"
            ;;
        opensuse*)
            PKG_MANAGER="zypper"
            # The most German package manager name in existence
            ;;
        *)
            print_error "Unsupported distribution: $DISTRO"
            print_info "Please install packages manually"
            print_warning "Or maybe consider switching to a distro from this decade?"
            exit 1
            ;;
    esac
    
    print_info "Detected distribution: $DISTRO"
    print_info "Package manager: $PKG_MANAGER"
    
    # Call the easter egg (maybe)
    print_sarcasm
}

# ========================================
# Install Packages
# ========================================

install_packages() {
    print_header "Installing Required Packages"
    
    # Fun fact: You're about to download more eye candy than actual productivity tools
    
    case "$PKG_MANAGER" in
        apt)
            print_info "Updating package list..."
            print_warning "(This is where Ubuntu users go make coffee)"
            sudo apt update
            
            PACKAGES=(
                "zsh"           # Because bash is for boomers
                "git"           # You already have this, but just in case
                "curl"          # For downloading more things to procrastinate with
                "wget"          # Because why have one download tool when you can have two?
                "fontconfig"    # So your terminal doesn't look like Windows 95
                "btop"          # htop's cooler younger sibling
                "cava"          # Making your music look as good as it sounds (productivity: -50%)
                "kitty"         # Not the animal, unfortunately
                "htop"          # For when btop is too mainstream
                "python3"       # Snake language best language
                "python3-pip"   # Pip install disappointment
                "i3"            # Tiling WM for people who enjoy suffering
                "wofi"          # dmenu but make it ✨fancy✨
                "gparted"       # For when you inevitably mess up your partitions
                "cmatrix"       # Because you need to feel like a hacker
            )
            
            # Install packages
            for pkg in "${PACKAGES[@]}"; do
                if dpkg -l | grep -q "^ii  $pkg "; then
                    print_success "$pkg already installed"
                else
                    print_info "Installing $pkg..."
                    sudo apt install -y "$pkg" || print_warning "Failed to install $pkg (skill issue?)"
                fi
            done
            
            # Install fastfetch from GitHub releases
            if ! command -v fastfetch &> /dev/null; then
                print_info "Installing fastfetch..."
                print_info "(neofetch died for this)"
                wget -q https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb
                sudo dpkg -i fastfetch-linux-amd64.deb
                rm fastfetch-linux-amd64.deb
            else
                print_success "fastfetch already installed"
            fi
            ;;
            
        pacman)
            print_info "Updating package database..."
            print_success "Confirmed: You use Arch. We get it."
            sudo pacman -Sy
            
            PACKAGES=(
                "zsh"
                "git"
                "curl"
                "wget"
                "fontconfig"
                "btop"
                "cava"
                "kitty"
                "htop"
                "python"
                "python-pip"
                "i3-wm"
                "wofi"
                "gparted"
                "cmatrix"
                "fastfetch"
            )
            
            # Install packages
            for pkg in "${PACKAGES[@]}"; do
                if pacman -Q "$pkg" &> /dev/null; then
                    print_success "$pkg already installed"
                else
                    print_info "Installing $pkg..."
                    sudo pacman -S --noconfirm "$pkg" || print_warning "Failed to install $pkg"
                fi
            done
            ;;
            
        dnf)
            print_info "Updating package metadata..."
            sudo dnf check-update || true
            
            PACKAGES=(
                "zsh"
                "git"
                "curl"
                "wget"
                "fontconfig"
                "btop"
                "cava"
                "kitty"
                "htop"
                "python3"
                "python3-pip"
                "i3"
                "wofi"
                "gparted"
                "cmatrix"
            )
            
            # Install packages
            for pkg in "${PACKAGES[@]}"; do
                if rpm -q "$pkg" &> /dev/null; then
                    print_success "$pkg already installed"
                else
                    print_info "Installing $pkg..."
                    sudo dnf install -y "$pkg" || print_warning "Failed to install $pkg"
                fi
            done
            
            # Install fastfetch
            if ! command -v fastfetch &> /dev/null; then
                print_info "Installing fastfetch..."
                wget -q https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.rpm
                sudo dnf install -y fastfetch-linux-amd64.rpm
                rm fastfetch-linux-amd64.rpm
            fi
            ;;
    esac
    
    # Install Python packages
    print_info "Installing Python packages..."
    pip3 install --user pywal || print_warning "Failed to install pywal"
    
    # Install neofetch (optional, as fallback to fastfetch)
    if ! command -v neofetch &> /dev/null; then
        print_info "Installing neofetch..."
        print_warning "RIP neofetch (2015-2024) - You were too beautiful for this world"
        git clone https://github.com/dylanaraps/neofetch /tmp/neofetch
        cd /tmp/neofetch
        sudo make install
        cd -
        rm -rf /tmp/neofetch
    fi
    
    print_success "Package installation completed!"
    print_info "Your terminal is now 69% cooler"
}

# ========================================
# Install Lazygit
# ========================================

install_lazygit() {
    print_header "Installing Lazygit"
    
    if command -v lazygit &> /dev/null; then
        print_success "Lazygit already installed"
        print_info "(For when you're too lazy to git gud)"
        return
    fi
    
    print_info "Installing lazygit... (ironically, the manual way)"
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz
    
    print_success "Lazygit installed successfully!"
}

# ========================================
# Install Lazydocker
# ========================================

install_lazydocker() {
    print_header "Installing Lazydocker"
    
    if command -v lazydocker &> /dev/null; then
        print_success "Lazydocker already installed"
        print_info "(Docker: Now with 20% less typing!)"
        return
    fi
    
    print_info "Downloading lazydocker..."
    print_warning "If this fails, just use docker-compose like the rest of us peasants"
    curl -s https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    
    print_success "Lazydocker installed successfully!"
}

# ========================================
# Install Oh My Zsh
# ========================================

install_ohmyzsh() {
    print_header "Installing Oh My Zsh"
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh already installed"
    else
        print_info "Installing Oh My Zsh..."
        print_info "Prepare for maximum terminal productivity (actual productivity may vary)"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed!"
    fi
    
    # Install zsh-autosuggestions
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        print_info "Installing zsh-autosuggestions..."
        print_info "(Because typing is hard)"
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        print_info "Installing zsh-syntax-highlighting..."
        print_info "(Pretty colors for your ls commands)"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi
    
    print_success "Oh My Zsh plugins installed!"
    print_info "Your shell is now officially fancier than your life"
}

# ========================================
# Install Powerlevel10k
# ========================================

install_p10k() {
    print_header "Installing Powerlevel10k"
    
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        print_success "Powerlevel10k already installed"
    else
        print_info "Installing Powerlevel10k..."
        print_warning "⚡ This theme has more power than your electricity bill"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        print_success "Powerlevel10k installed!"
        print_info "Your prompt is about to look better than your resume"
    fi
}

# ========================================
# Install Variety
# ========================================

install_variety() {
    print_header "Installing Variety"
    
    if command -v variety &> /dev/null; then
        print_success "Variety already installed"
        return
    fi
    
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
}

# ========================================
# Backup Existing Configs
# ========================================

backup_configs() {
    print_header "Backing Up Existing Configurations"
    
    mkdir -p "$BACKUP_DIR"
    
    print_info "Creating backup at: $BACKUP_DIR"
    print_warning "You know, just in case this script becomes sentient and goes rogue"
    
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
    
    for file in "${FILES_TO_BACKUP[@]}"; do
        if [ -e "$file" ]; then
            print_info "Backing up $file"
            cp -r "$file" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    
    print_success "Backup created at: $BACKUP_DIR"
    print_info "(You'll probably never use it, but it's there)"
}

# ========================================
# Install Dotfiles
# ========================================

install_dotfiles() {
    print_header "Installing Dotfiles"
    
    # Create necessary directories
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$HOME/.local/share/fonts"
    
    # Install fonts
    print_info "Installing fonts..."
    print_info "(So your terminal doesn't look like it's having a stroke)"
    if [ -d "$DOTFILES_DIR/.fonts" ]; then
        cp -r "$DOTFILES_DIR/.fonts/"* "$HOME/.local/share/fonts/" 2>/dev/null || true
        fc-cache -fv > /dev/null 2>&1
        print_success "Fonts installed! Your icons can now render properly!"
    fi
    
    # Symlink shell configs
    print_info "Symlinking shell configurations..."
    print_warning "If you break something, remember: ctrl+z is your friend (oh wait, wrong program)"
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
    ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
    
    # Symlink config directories
    CONFIG_DIRS=("btop" "cava" "fastfetch" "kitty" "wal" "wlogout" "i3" "wofi")
    
    for dir in "${CONFIG_DIRS[@]}"; do
        if [ -d "$DOTFILES_DIR/.config/$dir" ]; then
            print_info "Symlinking $dir config..."
            rm -rf "$CONFIG_DIR/$dir"
            ln -sf "$DOTFILES_DIR/.config/$dir" "$CONFIG_DIR/$dir"
        fi
    done
    
    # Copy wallpapers
    if [ -d "$DOTFILES_DIR/Pictures" ]; then
        print_info "Copying wallpapers..."
        print_info "(Because staring at default backgrounds is for normies)"
        mkdir -p "$HOME/Pictures/Wallpapers"
        cp -r "$DOTFILES_DIR/Pictures/"* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
    fi
    
    # Copy scripts
    if [ -d "$DOTFILES_DIR/.script" ]; then
        print_info "Installing scripts..."
        print_warning "These scripts have more power than sudo. Use responsibly."
        mkdir -p "$HOME/.local/bin"
        cp -r "$DOTFILES_DIR/.script/"* "$HOME/.local/bin/" 2>/dev/null || true
        chmod +x "$HOME/.local/bin/"*.sh 2>/dev/null || true
    fi
    
    # Copy DDD config if exists
    if [ -d "$DOTFILES_DIR/.ddd" ]; then
        print_info "Copying DDD config..."
        print_info "(For the 3 people who actually use DDD)"
        cp -r "$DOTFILES_DIR/.ddd" "$HOME/"
    fi
    
    print_success "Dotfiles installed successfully!"
    print_info "Congratulations! You're now 420% more likely to screenshot your terminal"
}

# ========================================
# Set Zsh as Default Shell
# ========================================

set_default_shell() {
    print_header "Setting Zsh as Default Shell"
    
    if [ "$SHELL" != "$(which zsh)" ]; then
        if ask_yes_no "Would you like to set zsh as your default shell?"; then
            chsh -s "$(which zsh)"
            print_success "Zsh set as default shell (restart required)"
            print_info "bash users in shambles rn"
        else
            print_info "Skipping shell change"
            print_warning "Coward. (jk bash is fine... I guess)"
        fi
    else
        print_success "Zsh is already your default shell"
        print_info "A person of culture, I see"
    fi
}

# ========================================
# Optional Installations
# ========================================

install_optional() {
    print_header "Optional Installations"
    
    print_info "Time for the fun stuff (read: unnecessary bloat you absolutely need)"
    
    # BetterDiscord
    if ask_yes_no "Install BetterDiscord?"; then
        print_info "Installing BetterDiscord..."
        print_warning "Discord ToS: ❌ | Cool themes: ✅"
        curl -O https://raw.githubusercontent.com/BetterDiscord/BetterDiscord/main/scripts/install.sh
        bash install.sh
        rm install.sh
        print_success "BetterDiscord installer run!"
        print_info "(Discord's legal team wants to know your location)"
    fi
    
    # Momoisay
    if ask_yes_no "Install momoisay (cowsay alternative)?"; then
        if command -v go &> /dev/null; then
            print_info "Installing momoisay..."
            print_info "Because cowsay is too mainstream"
            go install github.com/sudoblark/momoisay@latest
            print_success "Momoisay installed!"
        else
            print_warning "Go is not installed. Skipping momoisay."
            print_info "What are you, some kind of Python-only peasant?"
        fi
    fi
    
    # Wlogout
    if ask_yes_no "Install wlogout?"; then
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
        print_info "Now you can logout in S T Y L E ✨"
    fi
}

# ========================================
# Post Installation
# ========================================

post_install() {
    print_header "Post Installation Setup"
    
    # Apply pywal theme if wallpapers exist
    if [ -d "$HOME/Pictures/Wallpapers" ] && command -v wal &> /dev/null; then
        print_info "Applying pywal theme..."
        print_info "(Generating color schemes with SCIENCE)"
        WALLPAPER=$(find "$HOME/Pictures/Wallpapers" -type f | head -n 1)
        if [ -n "$WALLPAPER" ]; then
            wal -i "$WALLPAPER" > /dev/null 2>&1
            print_success "Pywal theme applied! Your terminal is now A E S T H E T I C"
        fi
    fi
    
    print_success "Installation completed!"
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  🎉 CONGRATULATIONS! 🎉                       ║${NC}"
    echo -e "${GREEN}║                                                ║${NC}"
    echo -e "${GREEN}║  You've successfully wasted... I mean         ║${NC}"
    echo -e "${GREEN}║  invested your time in terminal aesthetics!   ║${NC}"
    echo -e "${GREEN}║                                                ║${NC}"
    echo -e "${GREEN}║  Your productivity: 📉                        ║${NC}"
    echo -e "${GREEN}║  Your terminal's looks: 📈📈📈              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_info "Backup location: $BACKUP_DIR"
    print_warning "Please restart your terminal or log out and log back in"
    print_warning "(Or just open a new tab if you're too lazy)"
    echo ""
    print_info "To complete the setup:"
    echo "  1. Restart your terminal (or source ~/.zshrc like a pro)"
    echo "  2. Run: p10k configure"
    echo "  3. Take 47 screenshots"
    echo "  4. Post on r/unixporn"
    echo "  5. Refuse to elaborate"
    echo "  6. Profit???"
    echo ""
    print_success "May your terminal be forever aesthetic! ✨"
    echo ""
    print_info "P.S. - If something broke, that's a feature, not a bug 🐛"
}

# ========================================
# Main Installation Flow
# ========================================

main() {
    clear
    
    echo -e "${MAGENTA}"
    cat << "EOF"
    ╔════════════════════════════════════════╗
    ║  🍚 Linux Dotfiles Installer 🥢      ║
    ╚════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${CYAN}Fun fact: You could've been productive by now.${NC}"
    echo -e "${CYAN}But no, you chose aesthetics. Respect. 🫡${NC}"
    echo ""
    
    print_warning "This script will:"
    echo "  • Install packages (the fun kind)"
    echo "  • Modify your configs (scary!)"
    echo "  • Make your terminal actually usable (revolutionary!)"
    echo "  • Consume approximately 69% of your free time"
    echo ""
    
    print_info "A backup will be created at: $BACKUP_DIR"
    print_warning "(Which you'll never use, but hey, it's there)"
    echo ""
    
    if ! ask_yes_no "Ready to rice your system?"; then
        print_info "Installation cancelled."
        print_warning "Fine. Go back to your vanilla terminal. See if I care."
        exit 0
    fi
    
    echo ""
    
    # The point of no return...
    print_info "🚀 Initiating rice sequence..."
    print_warning "There's no turning back now. This is your life now."
    sleep 1
    
    # Detect distribution
    detect_distro
    
    # Run installation steps
    backup_configs
    install_packages
    install_lazygit
    install_lazydocker
    install_ohmyzsh
    install_p10k
    install_variety
    install_dotfiles
    install_optional
    set_default_shell
    post_install
}

# Hidden easter egg - if you run with --help
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Usage: ./install.sh"
    echo ""
    echo "Options:"
    echo "  --help, -h     Show this help message"
    echo "  --yolo         Skip all confirmations (not recommended)"
    echo "  --serious      Remove all jokes (why would you do this?)"
    echo "  --hack-nasa    Not implemented yet, come back in 2077"
    echo ""
    echo "This script will install dotfiles and make your terminal aesthetic AF."
    echo "Side effects may include: terminal addiction, screenshot obsession,"
    echo "inability to use default themes, and spontaneous r/unixporn posting."
    echo ""
    echo "Remember: With great power comes great responsibility to rice."
    exit 0
fi

# Another easter egg - --hack-nasa
if [ "$1" == "--hack-nasa" ]; then
    echo "Hacking NASA..."
    for i in {1..100}; do
        echo -ne "█"
        sleep 0.01
    done
    echo ""
    echo ""
    echo "Just kidding. Go touch grass."
    exit 0
fi

# Run main function
main "$@"
