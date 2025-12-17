#!/bin/bash

# ============================================================================
# 🍚 Linux Dotfiles Installer 🥢
# ============================================================================
# WARNING: This script will touch your dotfiles in ways that may make you
# uncomfortable. Proceed with caution and a sense of humor.
# ============================================================================

set -o pipefail

# ANSI Colors - Using tput for terminal-independent colors (pywal can't touch these)
if command -v tput &> /dev/null && [[ -n "$TERM" ]]; then
    RED=$(tput setaf 196)      # Bright red
    GREEN=$(tput setaf 46)     # Bright green
    YELLOW=$(tput setaf 226)   # Bright yellow
    BLUE=$(tput setaf 51)      # Bright cyan-blue
    PURPLE=$(tput setaf 201)   # Hot pink/magenta
    ORANGE=$(tput setaf 208)   # Orange
    CYAN=$(tput setaf 87)      # Bright cyan
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    # Fallback to ANSI escape codes if tput fails
    RED='\033[38;5;196m'
    GREEN='\033[38;5;46m'
    YELLOW='\033[38;5;226m'
    BLUE='\033[38;5;51m'
    PURPLE='\033[38;5;201m'
    ORANGE='\033[38;5;208m'
    CYAN='\033[38;5;87m'
    BOLD='\033[1m'
    RESET='\033[0m'
fi

# Easter egg counter
EASTER_EGG_COUNT=0

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo -e "${PURPLE}${BOLD}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║     🍚  LINUX DOTFILES INSTALLER  🥢                      ║
    ║                                                           ║
    ║     "Making your terminal sexy since 5 minutes ago"      ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
}

print_success() {
    echo -e "${GREEN}${BOLD}✓${RESET} ${GREEN}$1${RESET}"
}

print_error() {
    echo -e "${RED}${BOLD}✗${RESET} ${RED}$1${RESET}"
}

print_warning() {
    echo -e "${ORANGE}${BOLD}⚠${RESET} ${ORANGE}$1${RESET}"
}

print_info() {
    echo -e "${BLUE}${BOLD}ℹ${RESET} ${CYAN}$1${RESET}"
}

print_joke() {
    local jokes=(
        "Installing dependencies... Your package manager works harder than you do"
        "Symlinking files... It's like marriage but without the emotional baggage"
        "Copying fonts... Because even your terminal deserves better than your dating life"
        "Setting up zsh... Sorry bash, but you're the ex we don't talk about"
        "Configuring btop... Finally, something that monitors resources better than your mom monitors your life"
        "This is taking longer than your last relationship"
        "Still loading... Unlike your work ethic"
        "Pro tip: Deleting /usr speeds this up by 100% (don't actually do this you beautiful idiot)"
        "Your terminal will look so good, you'll forget about your crippling student debt for a moment"
        "Fun fact: 92% of Linux ricing is just avoiding actual responsibilities"
        "Compiling... Just kidding, we're not Gentoo savages"
        "Installing... Your crush's response time is slower than this"
        "Processing... Still faster than government websites"
        "Loading... Your therapist would have a field day with this obsession"
    )
    echo -e "${YELLOW}${BOLD}💭${RESET} ${YELLOW}${jokes[$RANDOM % ${#jokes[@]}]}${RESET}"
}

easter_egg() {
    ((EASTER_EGG_COUNT++))
    case $EASTER_EGG_COUNT in
        1) 
            echo -e "${PURPLE}${BOLD}🥚 EASTER EGG #1!${RESET} ${PURPLE}You found one! Unlike your dad who's still looking for cigarettes${RESET}" 
            ;;
        2) 
            echo -e "${PURPLE}${BOLD}🥚 EASTER EGG #2!${RESET} ${PURPLE}Two eggs! That's more achievements than your LinkedIn profile${RESET}" 
            ;;
        3) 
            echo -e "${PURPLE}${BOLD}🥚 EASTER EGG #3!${RESET} ${PURPLE}Three eggs! You're now legally qualified to call yourself a 'power user'${RESET}" 
            ;;
        4) 
            echo -e "${PURPLE}${BOLD}🥚 EASTER EGG #4!${RESET} ${PURPLE}Four eggs! At this point you're just procrastinating. I respect it.${RESET}" 
            ;;
        5) 
            echo -e "${PURPLE}${BOLD}🥚🥚🥚🥚🥚 MEGA COMBO!${RESET} ${PURPLE}Five eggs! Here's the secret: 'sudo rm -rf --no-preserve-root /' gives you unlimited power! (DO NOT RUN THIS YOU ABSOLUTE WEAPON)${RESET}" 
            ;;
    esac
}

check_if_running_as_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Hold up! Don't run this as root!"
        print_warning "That's like using sudo on a first date - unnecessarily aggressive"
        print_info "Run it as a normal user. We're civilized here."
        exit 1
    fi
    easter_egg
}

ask_confirmation() {
    echo ""
    print_warning "⚠️  THIS WILL MODIFY YOUR DOTFILES ⚠️"
    print_info "Backups will be created at ~/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    print_info "If shit hits the fan, you can restore from there"
    echo ""
    read -p "$(echo -e ${CYAN}${BOLD}Continue? [y/N]: ${RESET})" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Installation cancelled.${RESET}"
        echo -e "${YELLOW}Your terminal remains boring. Like your personality. (jk love you)${RESET}"
        exit 0
    fi
    easter_egg
}

create_backup() {
    BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    print_info "Creating backup at $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # Backup existing configs
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
    [[ -f "$HOME/.bashrc" ]] && cp "$HOME/.bashrc" "$BACKUP_DIR/"
    [[ -f "$HOME/.p10k.zsh" ]] && cp "$HOME/.p10k.zsh" "$BACKUP_DIR/"
    [[ -d "$HOME/.config/btop" ]] && cp -r "$HOME/.config/btop" "$BACKUP_DIR/"
    [[ -d "$HOME/.config/cava" ]] && cp -r "$HOME/.config/cava" "$BACKUP_DIR/"
    [[ -d "$HOME/.config/fastfetch" ]] && cp -r "$HOME/.config/fastfetch" "$BACKUP_DIR/"
    
    print_success "Backup created! (You'll probably never need it but better safe than crying)"
    print_joke
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$ID
        print_info "Detected distro: $NAME"
        
        # Distro roasting because why not
        case $DISTRO in
            arch|manjaro)
                echo -e "${YELLOW}Ah yes, Arch. I can already hear you telling people you use Arch.${RESET}"
                ;;
            ubuntu|debian|pop|linuxmint)
                echo -e "${YELLOW}Ubuntu-based? Playing it safe I see. Nothing wrong with that, normie.${RESET}"
                ;;
            fedora)
                echo -e "${YELLOW}Fedora! The hipster's choice. Let me guess, you also drink craft beer?${RESET}"
                ;;
        esac
    else
        print_error "Can't detect your distro. Are you running TempleOS?"
        DISTRO="unknown"
    fi
}

check_dependencies() {
    print_info "Checking if you have the bare minimum installed..."
    
    local missing_deps=()
    local deps=(git zsh curl)
    
    for dep in "${deps[@]}"; do
        if ! command -v $dep &> /dev/null; then
            missing_deps+=($dep)
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
        print_info "Installing them now... (this is where things get spicy)"
        
        case $DISTRO in
            arch|manjaro)
                sudo pacman -Sy --noconfirm --needed ${missing_deps[*]}
                ;;
            ubuntu|debian|pop|linuxmint)
                sudo apt update && sudo apt install -y ${missing_deps[*]}
                ;;
            fedora|rhel|centos)
                sudo dnf install -y ${missing_deps[*]}
                ;;
            *)
                print_error "Your distro is too exotic for me"
                print_info "Manually install: ${missing_deps[*]}"
                print_warning "Or just use Arch like a normal person (jk)"
                exit 1
                ;;
        esac
    else
        print_success "All basic dependencies found! You're not completely hopeless!"
    fi
    easter_egg
}

install_optional_packages() {
    echo ""
    print_info "Time for the fancy optional stuff (btop, cava, fastfetch, pywal)"
    print_info "This is what separates you from the Windows peasants"
    read -p "$(echo -e ${CYAN}${BOLD}Install optional packages? [Y/n]: ${RESET})" -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        print_joke
        
        case $DISTRO in
            arch|manjaro)
                print_info "Installing via pacman (btw I use Arch)"
                sudo pacman -Sy --noconfirm --needed btop cava fastfetch python-pywal
                ;;
            ubuntu|debian|pop|linuxmint)
                print_info "Installing via apt (the Debian way of life)"
                sudo apt install -y btop cava fastfetch python3-pywal || {
                    print_warning "Some packages might not exist in your repos. Your repos are weak."
                }
                ;;
            fedora|rhel|centos)
                print_info "Installing via dnf (Red Hat gang rise up)"
                sudo dnf install -y btop cava fastfetch python3-pywal || {
                    print_warning "Some packages might need EPEL. Google it."
                }
                ;;
            *)
                print_warning "Can't auto-install on your hipster distro"
                print_info "You're on your own, chief. Good luck."
                ;;
        esac
        print_success "Optional packages installed (or at least we tried really hard)"
    else
        print_info "Skipping optional packages. Your loss, loser!"
        echo -e "${YELLOW}Just kidding, you're making practical choices. Boring, but practical.${RESET}"
    fi
}

install_ohmyzsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_info "Installing Oh My Zsh... (Because vanilla zsh is like vodka without the fun)"
        print_joke
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
            print_warning "Oh My Zsh installation had a moment, but we're pushing through"
        }
        print_success "Oh My Zsh installed! Your shell game just got stronger!"
    else
        print_success "Oh My Zsh already installed (look at you being prepared)"
    fi
}

install_powerlevel10k() {
    local P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ ! -d "$P10K_DIR" ]]; then
        print_info "Installing Powerlevel10k... (The prompt so good it makes people jealous)"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" || {
            print_error "Failed to clone Powerlevel10k. Is your internet as slow as Internet Explorer?"
            return 1
        }
        print_success "Powerlevel10k installed! Terminal envy incoming!"
    else
        print_success "Powerlevel10k already installed (you absolute legend)"
    fi
    easter_egg
}

install_fonts() {
    print_info "Installing Nerd Fonts... (So your terminal doesn't look like it's having a stroke)"
    
    mkdir -p ~/.local/share/fonts
    
    if [[ -d "$HOME/linux-dotfiles/.fonts" ]]; then
        cp -r "$HOME/linux-dotfiles/.fonts/"* ~/.local/share/fonts/
        fc-cache -fv > /dev/null 2>&1
        print_success "Fonts installed! Your icons should now render instead of showing □□□"
    else
        print_warning "Font directory not found. Did you clone the repo or just wing it?"
        print_info "Run: git clone https://github.com/NajElaoud/Linux-Dotfiles.git ~/linux-dotfiles"
    fi
    print_joke
}

symlink_configs() {
    print_info "Creating symbolic links... (It's like shortcuts but for people with taste)"
    
    local DOTFILES_DIR="$HOME/linux-dotfiles"
    
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        print_error "Dotfiles directory not found at $DOTFILES_DIR"
        print_warning "Did you forget to clone the repo? That's like showing up to a party empty-handed."
        exit 1
    fi
    
    # Symlink shell configs
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
    ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
    print_success "Shell configs linked!"
    
    # Create .config dirs if they don't exist
    mkdir -p ~/.config/{btop,cava,fastfetch,wal,wlogout}
    
    # Symlink application configs
    [[ -d "$DOTFILES_DIR/.config/btop" ]] && ln -sf "$DOTFILES_DIR/.config/btop/"* ~/.config/btop/ 2>/dev/null
    [[ -d "$DOTFILES_DIR/.config/cava" ]] && ln -sf "$DOTFILES_DIR/.config/cava/"* ~/.config/cava/ 2>/dev/null
    [[ -d "$DOTFILES_DIR/.config/fastfetch" ]] && ln -sf "$DOTFILES_DIR/.config/fastfetch/"* ~/.config/fastfetch/ 2>/dev/null
    [[ -d "$DOTFILES_DIR/.config/wal" ]] && ln -sf "$DOTFILES_DIR/.config/wal/"* ~/.config/wal/ 2>/dev/null
    [[ -d "$DOTFILES_DIR/.config/wlogout" ]] && ln -sf "$DOTFILES_DIR/.config/wlogout/"* ~/.config/wlogout/ 2>/dev/null
    
    print_success "Application configs linked!"
    print_joke
}

change_default_shell() {
    if [[ "$SHELL" != *"zsh"* ]]; then
        print_info "Changing default shell to zsh..."
        print_warning "You'll need to enter your password (no, not your Pornhub password, your system password)"
        chsh -s "$(which zsh)" || {
            print_error "Failed to change shell. Your system is being difficult."
            print_info "Manually run: chsh -s \$(which zsh)"
            return 1
        }
        print_success "Default shell changed to zsh! Logout and back in to activate."
    else
        print_success "Already using zsh! You're already winning at life!"
    fi
    easter_egg
}

print_final_message() {
    echo ""
    echo -e "${GREEN}${BOLD}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║           🎉  INSTALLATION COMPLETE!  🎉                  ║
    ║                                                           ║
    ║     Your terminal is now 420% more aesthetic              ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
    
    print_success "✓ Configs backed up (you'll probably never need them)"
    print_success "✓ Dependencies installed (you're no longer a script kiddie)"
    print_success "✓ Oh My Zsh + Powerlevel10k installed (terminal drip activated)"
    print_success "✓ Fonts installed (goodbye missing glyphs)"
    print_success "✓ Configs symlinked (professional af)"
    print_success "✓ Shell changed to zsh (bash who?)"
    
    echo ""
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════${RESET}"
    echo -e "${BLUE}${BOLD}NEXT STEPS:${RESET}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${ORANGE}1.${RESET} ${CYAN}Logout and login${RESET} (or restart your terminal like a normie)"
    echo -e "  ${ORANGE}2.${RESET} ${CYAN}Run 'p10k configure'${RESET} to customize your prompt to your heart's desire"
    echo -e "  ${ORANGE}3.${RESET} ${CYAN}Check out wallpapers${RESET} in ~/linux-dotfiles/Pictures/"
    echo -e "  ${ORANGE}4.${RESET} ${CYAN}Run 'fastfetch'${RESET} to flex your new setup on Reddit"
    echo -e "  ${ORANGE}5.${RESET} ${CYAN}Take screenshots${RESET} and post to r/unixporn for that sweet karma"
    echo ""
    
    if [[ $EASTER_EGG_COUNT -gt 0 ]]; then
        echo -e "${PURPLE}${BOLD}═══════════════════════════════════════════════════════════${RESET}"
        echo -e "${PURPLE}${BOLD}🥚 EASTER EGG HUNTER STATS 🥚${RESET}"
        echo -e "${PURPLE}${BOLD}═══════════════════════════════════════════════════════════${RESET}"
        echo -e "${PURPLE}You found ${BOLD}$EASTER_EGG_COUNT${RESET}${PURPLE} out of 5 easter eggs!${RESET}"
        
        if [[ $EASTER_EGG_COUNT -eq 5 ]]; then
            echo -e "${PURPLE}${BOLD}LEGENDARY STATUS ACHIEVED!${RESET}"
            echo -e "${PURPLE}You read everything. You're either very thorough or very bored.${RESET}"
            echo -e "${PURPLE}Either way, I respect it. Here's a cookie: 🍪${RESET}"
        elif [[ $EASTER_EGG_COUNT -ge 3 ]]; then
            echo -e "${PURPLE}Not bad! You're pretty observant. Unlike your code reviews.${RESET}"
        else
            echo -e "${PURPLE}You missed some eggs. They were funnier than your jokes.${RESET}"
        fi
        echo -e "${PURPLE}${BOLD}═══════════════════════════════════════════════════════════${RESET}"
        echo ""
    fi
    
    print_warning "⚠️  If something broke: restore from $BACKUP_DIR"
    print_info "💡  If everything works: Star the repo on GitHub (shameless plug)"
    print_info "🐛  If you find bugs: That's a feature, not a bug"
    echo ""
    
    # Final fortune
    local fortunes=(
        "Remember: It's not procrastination, it's terminal optimization"
        "Your productivity decreased by 69% but your terminal looks unfuckingbelievable"
        "Congratulations! You now spend more time in terminal than on Pornhub"
        "Fun fact: This installer has more personality than your Tinder bio"
        "You are now legally required to flex this setup on r/unixporn"
        "Your coworkers will ask 'how did you do that?' and you'll say 'I'm just built different'"
        "This terminal setup has more commitment than your last relationship"
        "You've ascended to a higher plane of existence. Windows users fear you now."
        "Your terminal is now hotter than your search history"
        "Achievement unlocked: Linux Rice God 🍚"
    )
    echo -e "${YELLOW}${BOLD}💭 ${fortunes[$RANDOM % ${#fortunes[@]}]}${RESET}"
    echo ""
    echo -e "${CYAN}${BOLD}May your commits be clean and your terminals be aesthetic. ✨${RESET}"
    echo ""
    echo -e "${PURPLE}Now go forth and rice, you beautiful bastard! 🚀${RESET}"
    echo ""
}

# ============================================================================
# Main Installation Flow
# ============================================================================

main() {
    print_header
    
    # Pre-flight checks
    check_if_running_as_root
    detect_distro
    ask_confirmation
    
    # The actual work
    create_backup
    check_dependencies
    install_optional_packages
    install_ohmyzsh
    install_powerlevel10k
    install_fonts
    symlink_configs
    change_default_shell
    
    # Victory lap
    print_final_message
}

# Run it!
main "$@"
