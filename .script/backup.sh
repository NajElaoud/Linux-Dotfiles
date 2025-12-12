#!/bin/bash

# ========================================
# 💾 Dotfiles Backup Script
# ========================================
# Creates timestamped backups of your configs
# Because "it works on my machine" is temporary
# ========================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_DIR="$HOME/.dotfiles_backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CURRENT_BACKUP="$BACKUP_DIR/backup_$TIMESTAMP"

print_header() {
    echo -e "${CYAN}=========================================="
    echo "  $1"
    echo "==========================================${NC}"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# Create backup directory
mkdir -p "$CURRENT_BACKUP"

print_header "Creating Backup"
print_info "Backup location: $CURRENT_BACKUP"
echo ""

# Files and directories to backup
ITEMS_TO_BACKUP=(
    "$HOME/.zshrc"
    "$HOME/.bashrc"
    "$HOME/.p10k.zsh"
    "$HOME/.config/btop"
    "$HOME/.config/cava"
    "$HOME/.config/fastfetch"
    "$HOME/.config/kitty"
    "$HOME/.config/wal"
    "$HOME/.config/wlogout"
    "$HOME/.config/i3"
    "$HOME/.config/wofi"
    "$HOME/.config/nvim"
    "$HOME/.gitconfig"
    "$HOME/.tmux.conf"
)

# Backup each item
for item in "${ITEMS_TO_BACKUP[@]}"; do
    if [ -e "$item" ]; then
        print_info "Backing up $(basename "$item")..."
        cp -r "$item" "$CURRENT_BACKUP/" 2>/dev/null || true
    fi
done

# Create a tarball
print_info "Creating compressed archive..."
cd "$BACKUP_DIR"
tar -czf "backup_$TIMESTAMP.tar.gz" "backup_$TIMESTAMP"
rm -rf "backup_$TIMESTAMP"

BACKUP_SIZE=$(du -h "backup_$TIMESTAMP.tar.gz" | cut -f1)

echo ""
print_success "Backup completed!"
print_info "Archive: backup_$TIMESTAMP.tar.gz"
print_info "Size: $BACKUP_SIZE"
print_info "Location: $BACKUP_DIR"

# Keep only last 5 backups
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR" | wc -l)
if [ "$BACKUP_COUNT" -gt 5 ]; then
    print_warning "Removing old backups (keeping last 5)..."
    cd "$BACKUP_DIR"
    ls -t | tail -n +6 | xargs rm -f
fi

echo ""
print_info "To restore: tar -xzf $BACKUP_DIR/backup_$TIMESTAMP.tar.gz -C ~"
