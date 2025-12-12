#!/bin/bash

# ========================================
# 🎨 Interactive Theme Switcher
# ========================================
# Switch between wallpapers and color schemes
# with style and grace (and fzf if you have it)
# ========================================

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WAL_CACHE="$HOME/.cache/wal"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear

echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════╗
║     🎨 Theme Switcher 🎨          ║
╚════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if pywal is installed
if ! command -v wal &> /dev/null; then
    echo -e "${YELLOW}⚠ pywal is not installed!${NC}"
    echo "Install it with: pip3 install pywal"
    exit 1
fi

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo -e "${YELLOW}⚠ Wallpaper directory not found: $WALLPAPER_DIR${NC}"
    exit 1
fi

# Count wallpapers
WALLPAPER_COUNT=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | wc -l)

if [ "$WALLPAPER_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠ No wallpapers found in $WALLPAPER_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}Found $WALLPAPER_COUNT wallpapers!${NC}"
echo ""

# Menu options
echo "Choose an option:"
echo "  1) Random wallpaper (YOLO mode)"
echo "  2) Browse and select (civilized approach)"
echo "  3) Dark theme preference"
echo "  4) Light theme preference"
echo "  5) Show current theme"
echo "  6) Restore previous theme"
echo "  0) Exit (boring)"
echo ""

read -p "Enter your choice: " choice

case $choice in
    1)
        # Random wallpaper
        echo -e "${CYAN}🎲 Rolling the dice...${NC}"
        RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
        
        echo "Selected: $(basename "$RANDOM_WALLPAPER")"
        wal -i "$RANDOM_WALLPAPER"
        
        # Set as wallpaper (if using variety or feh)
        if command -v variety &> /dev/null; then
            variety --set "$RANDOM_WALLPAPER" 2>/dev/null
        elif command -v feh &> /dev/null; then
            feh --bg-fill "$RANDOM_WALLPAPER" 2>/dev/null
        fi
        
        echo -e "${GREEN}✓ Theme applied!${NC}"
        ;;
        
    2)
        # Browse with fzf if available, otherwise use select
        if command -v fzf &> /dev/null; then
            echo -e "${CYAN}📋 Use arrow keys to browse, Enter to select${NC}"
            SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | fzf --preview 'echo {}; file {}' --preview-window=up:3)
        else
            echo -e "${CYAN}📋 Select a wallpaper:${NC}"
            mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \))
            
            select SELECTED in "${WALLPAPERS[@]}"; do
                [ -n "$SELECTED" ] && break
            done
        fi
        
        if [ -n "$SELECTED" ]; then
            echo "Applying: $(basename "$SELECTED")"
            wal -i "$SELECTED"
            
            if command -v variety &> /dev/null; then
                variety --set "$SELECTED" 2>/dev/null
            elif command -v feh &> /dev/null; then
                feh --bg-fill "$SELECTED" 2>/dev/null
            fi
            
            echo -e "${GREEN}✓ Theme applied!${NC}"
        else
            echo "No wallpaper selected"
        fi
        ;;
        
    3)
        # Dark theme
        echo -e "${CYAN}🌙 Applying dark theme...${NC}"
        WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
        wal -i "$WALLPAPER" --backend colorz --saturate 0.5
        echo -e "${GREEN}✓ Dark theme applied!${NC}"
        ;;
        
    4)
        # Light theme
        echo -e "${CYAN}☀️  Applying light theme...${NC}"
        WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
        wal -i "$WALLPAPER" -l
        echo -e "${GREEN}✓ Light theme applied!${NC}"
        echo -e "${YELLOW}Warning: Your eyes may experience confusion${NC}"
        ;;
        
    5)
        # Show current theme
        if [ -f "$WAL_CACHE/wal" ]; then
            echo -e "${CYAN}Current wallpaper:${NC}"
            cat "$WAL_CACHE/wal"
            echo ""
            echo -e "${CYAN}Current color scheme:${NC}"
            cat "$WAL_CACHE/colors.sh"
        else
            echo -e "${YELLOW}No theme is currently applied${NC}"
        fi
        ;;
        
    6)
        # Restore previous
        echo -e "${CYAN}🔄 Restoring previous theme...${NC}"
        wal -R
        echo -e "${GREEN}✓ Previous theme restored!${NC}"
        ;;
        
    0)
        echo "Exiting... (Your terminal stays beautiful though)"
        exit 0
        ;;
        
    *)
        echo -e "${YELLOW}Invalid choice. Try again, smarty pants.${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}╔════════════════════════════════════╗"
echo -e "║  ✨ Theme updated successfully! ✨ ║"
echo -e "║                                    ║"
echo -e "║  Restart terminal for full effect  ║"
echo -e "╚════════════════════════════════════╝${NC}"
echo ""
echo "Tip: Add this to your .zshrc to apply theme on startup:"
echo "  (cat ~/.cache/wal/sequences &)"
