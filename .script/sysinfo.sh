#!/bin/bash

# ========================================
# 🖥️  System Info Script
# ========================================
# Displays detailed system information
# For when fastfetch isn't extra enough
# ========================================

# Colors
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Icons (requires Nerd Font)
ICON_OS=""
ICON_KERNEL=""
ICON_CPU=""
ICON_MEM="󰍛"
ICON_DISK="󰋊"
ICON_SHELL=""
ICON_TERM=""
ICON_WM=""
ICON_UPTIME="󰔟"
ICON_PACKAGES="󰏖"

print_section() {
    echo -e "${CYAN}${BOLD}$1${NC}"
}

print_item() {
    echo -e "${BLUE}$1${NC} ${GREEN}$2${NC}"
}

clear

# Header
echo -e "${CYAN}${BOLD}"
cat << "EOF"
╔════════════════════════════════════════╗
║       System Information Dashboard      ║
╚════════════════════════════════════════╝
EOF
echo -e "${NC}"

# OS Information
print_section "📦 System"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    print_item "$ICON_OS  OS:" "$NAME $VERSION"
else
    print_item "$ICON_OS  OS:" "Unknown"
fi

print_item "$ICON_KERNEL  Kernel:" "$(uname -r)"
print_item "$ICON_UPTIME  Uptime:" "$(uptime -p | sed 's/up //')"
echo ""

# Hardware
print_section "🔧 Hardware"
print_item "$ICON_CPU  CPU:" "$(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
print_item "$ICON_MEM  RAM:" "$(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
print_item "$ICON_DISK  Disk:" "$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}')"
echo ""

# Shell Information
print_section "🐚 Shell & Terminal"
print_item "$ICON_SHELL  Shell:" "$SHELL"
print_item "$ICON_TERM  Terminal:" "${TERM}"

if [ -n "$DESKTOP_SESSION" ]; then
    print_item "$ICON_WM  Desktop:" "$DESKTOP_SESSION"
elif [ -n "$XDG_CURRENT_DESKTOP" ]; then
    print_item "$ICON_WM  Desktop:" "$XDG_CURRENT_DESKTOP"
fi
echo ""

# Package Count
print_section "📦 Packages"
if command -v dpkg &> /dev/null; then
    PKG_COUNT=$(dpkg -l | grep -c '^ii')
    print_item "$ICON_PACKAGES  Installed:" "$PKG_COUNT (dpkg)"
elif command -v pacman &> /dev/null; then
    PKG_COUNT=$(pacman -Q | wc -l)
    print_item "$ICON_PACKAGES  Installed:" "$PKG_COUNT (pacman)"
elif command -v rpm &> /dev/null; then
    PKG_COUNT=$(rpm -qa | wc -l)
    print_item "$ICON_PACKAGES  Installed:" "$PKG_COUNT (rpm)"
fi
echo ""

# Network
print_section "🌐 Network"
IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -n1)
print_item "󰩟  Local IP:" "${IP:-N/A}"

if command -v curl &> /dev/null; then
    PUBLIC_IP=$(curl -s ifconfig.me)
    print_item "󰩠  Public IP:" "${PUBLIC_IP:-N/A}"
fi
echo ""

# Resource Usage
print_section "📊 Resource Usage"
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
print_item "  CPU Usage:" "$CPU_USAGE"

MEM_USAGE=$(free | grep Mem | awk '{print int($3/$2 * 100)"%"}')
print_item "󰍛  RAM Usage:" "$MEM_USAGE"

DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
print_item "󰋊  Disk Usage:" "$DISK_USAGE"
echo ""

# Temperature (if available)
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
    TEMP_C=$((TEMP / 1000))
    print_section "🌡️  Temperature"
    print_item "  CPU Temp:" "${TEMP_C}°C"
    echo ""
fi

# Footer
echo -e "${CYAN}${BOLD}╔════════════════════════════════════════╗"
echo -e "║  Looking good! Keep that rice fresh 🍚 ║"
echo -e "╚════════════════════════════════════════╝${NC}"
