#!/bin/bash

# ========================================
# 🔄 Universal Update Script
# ========================================
# Updates everything: system, packages, dotfiles, plugins, etc.
# Run this weekly to keep your rice fresh 🍚
# ========================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}"
    echo "=========================================="
    echo "  $1"
    echo "=========================================="
    echo -e "${NC}"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }

# Detect package manager
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
else
    PKG_MANAGER="unknown"
fi

# ========================================
# Update System Packages
# ========================================

update_system() {
    print_header "Updating System Packages"
    
    case "$PKG_MANAGER" in
        apt)
            print_info "Updating apt packages..."
            sudo apt update && sudo apt upgrade -y
            sudo apt autoremove -y
            sudo apt autoclean
            ;;
        pacman)
            print_info "Updating pacman packages..."
            print_info "(BTW, you use Arch)"
            sudo pacman -Syu --noconfirm
            ;;
        dnf)
            print_info "Updating dnf packages..."
            sudo dnf upgrade -y
            sudo dnf autoremove -y
            ;;
        *)
            print_error "Unknown package manager"
            return 1
            ;;
    esac
    
    print_success "System packages updated!"
}

# ========================================
# Update Oh My Zsh
# ========================================

update_ohmyzsh() {
    print_header "Updating Oh My Zsh"
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_info "Updating Oh My Zsh..."
        cd "$HOME/.oh-my-zsh" && git pull
        print_success "Oh My Zsh updated!"
    else
        print_info "Oh My Zsh not installed, skipping..."
    fi
}

# ========================================
# Update Zsh Plugins
# ========================================

update_zsh_plugins() {
    print_header "Updating Zsh Plugins"
    
    # Update autosuggestions
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        print_info "Updating zsh-autosuggestions..."
        cd "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" && git pull
    fi
    
    # Update syntax highlighting
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        print_info "Updating zsh-syntax-highlighting..."
        cd "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" && git pull
    fi
    
    print_success "Zsh plugins updated!"
}

# ========================================
# Update Powerlevel10k
# ========================================

update_p10k() {
    print_header "Updating Powerlevel10k"
    
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        print_info "Updating Powerlevel10k..."
        cd "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" && git pull
        print_success "Powerlevel10k updated! ⚡"
    else
        print_info "Powerlevel10k not installed, skipping..."
    fi
}

# ========================================
# Update Python Packages
# ========================================

update_python() {
    print_header "Updating Python Packages"
    
    if command -v pip3 &> /dev/null; then
        print_info "Updating pip..."
        pip3 install --upgrade pip --user
        
        print_info "Updating pywal..."
        pip3 install --upgrade pywal --user
        
        print_success "Python packages updated!"
    fi
}

# ========================================
# Update Fastfetch
# ========================================

update_fastfetch() {
    print_header "Checking Fastfetch Updates"
    
    if command -v fastfetch &> /dev/null; then
        print_info "Current version: $(fastfetch --version | head -n1)"
        print_info "Check https://github.com/fastfetch-cli/fastfetch/releases for updates"
    fi
}

# ========================================
# Update Dotfiles from Git
# ========================================

update_dotfiles() {
    print_header "Updating Dotfiles from Git"
    
    if [ -d "$HOME/linux-dotfiles" ]; then
        print_info "Pulling latest dotfiles..."
        cd "$HOME/linux-dotfiles"
        
        # Stash any local changes
        git stash
        git pull origin main
        git stash pop
        
        print_success "Dotfiles updated!"
        print_info "Remember to re-symlink if needed!"
    else
        print_info "Dotfiles repo not found at ~/linux-dotfiles"
    fi
}

# ========================================
# Clean Package Cache
# ========================================

clean_cache() {
    print_header "Cleaning Package Cache"
    
    case "$PKG_MANAGER" in
        apt)
            sudo apt clean
            ;;
        pacman)
            sudo pacman -Sc --noconfirm
            ;;
        dnf)
            sudo dnf clean all
            ;;
    esac
    
    print_success "Cache cleaned!"
}

# ========================================
# Update Lazygit
# ========================================

update_lazygit() {
    print_header "Checking Lazygit Updates"
    
    if command -v lazygit &> /dev/null; then
        print_info "Current version: $(lazygit --version)"
        print_info "Visit https://github.com/jesseduffield/lazygit/releases for latest"
    fi
}

# ========================================
# Font Cache Refresh
# ========================================

refresh_fonts() {
    print_header "Refreshing Font Cache"
    
    print_info "Rebuilding font cache..."
    fc-cache -fv > /dev/null 2>&1
    print_success "Font cache refreshed!"
}

# ========================================
# Main Execution
# ========================================

main() {
    clear
    
    echo -e "${CYAN}"
    cat << "EOF"
    ╔════════════════════════════════════╗
    ║  🔄 Universal Update Script 🔄    ║
    ║                                    ║
    ║  "Update all the things!"         ║
    ╚════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    print_info "Starting comprehensive update..."
    echo ""
    
    # Run all updates
    update_system
    update_ohmyzsh
    update_zsh_plugins
    update_p10k
    update_python
    update_fastfetch
    update_dotfiles
    update_lazygit
    clean_cache
    refresh_fonts
    
    echo ""
    print_header "Update Complete!"
    
    echo -e "${GREEN}"
    cat << "EOF"
    ╔════════════════════════════════════╗
    ║  ✨ Everything is up to date! ✨  ║
    ╚════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    print_info "Recommended: Restart your terminal to apply all changes"
    print_info "Or just keep scrolling reddit, no judgment here"
}

# Run it
main "$@"
