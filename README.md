# 🍚 Linux Dotfiles 🥢

![Status: Rice Achieved](https://img.shields.io/badge/status-rice%20achieved-10B981)
![Productivity: Questionable](https://img.shields.io/badge/productivity-questionable-F59E0B)
![Works on My Machine](https://img.shields.io/badge/Works%20on-My%20Machine-059669)
![Hours Wasted](https://img.shields.io/badge/Hours%20Wasted-Too%20Many-DC2626)
![Commit Count](https://img.shields.io/badge/Commits-Way%20Too%20Many-D97706)

> *"I spent more time customizing my terminal than actually using it"* - Ancient Linux Proverb

![Linux Rice Full Setup](screenshots/full-setup.png)
*The whole shebang - when all your terminal windows align perfectly*

## 🎭 What's This?

Welcome to my dotfiles! AKA **"I Spent More Time Configuring My Terminal Than Actually Using It"** - The Repository™

Remember when you thought you'd just "quickly customize" your terminal? Yeah, 47 hours later, here we are. This is a lovingly over-engineered collection of configs, scripts, and digital incantations that transform a plain terminal into something that makes you go "ooh shiny" every time you open it. Is it productive? Debatable. Does it look cool? Absolutely.

This is basically my terminal's glow-up journey documented for posterity (and so I can remember what I did when I inevitably break everything).

### 🎪 The Origin Story

👉 This is my **first ever Linux rice**  
👉 My **first time** touching dotfiles  
👉 My **first GitHub upload** in this category  
Translation: I have no idea what I'm doing, but it *looks* pretty cool! 

So if things catch fire 🔥, computers start speaking Latin, or your cat learns to code and rewrites everything in Rust... well, we'll cross that bridge when we get there.
So… I *really* hope it doesn’t break my machine — or yours. 😬

**⚠️ DISCLAIMER:** I take no responsibility if your machine:
- Explodes 💥
- Accidentally boots into Windows 🪟
- Your cat suddenly gains root access and types `rm -rf /` 🐱
- Summons Linus Torvalds who personally roasts your code
- Opens a portal to the command line dimension 🌀

> **Pro tip:** Use [Timeshift](https://github.com/linuxmint/timeshift) or sacrifice a USB drive to the backup gods BEFORE installing. I learned this the hard way. You don't have to.

## 🎨 What Do You Get?

- **zsh** with Powerlevel10k (because bash is so 1989)
- **Nerd Fonts** (so your terminal doesn't look like: `□□□`)
- **btop** (htop's cooler cousin)
- **cava** (because your terminal needed a soundwave visualizer, obviously)
- **fastfetch** (neofetch but faster, like your excuses)
- **pywal** (auto-generate color schemes because manual theming is for mortals)
- **wlogout** (logout in style, because you're fancy)
- **Wallpapers** (more organized than my life)
- **Scripts** (automation > manual labor)

In short: Clone this, run the installer, and instantly have a setup that screams "I know what I'm doing" (even if you don't).

---

## 📂 What's Inside This Beautiful Mess?

```
📁 Home Directory Configs
├── .zshrc              ← The heart of the operation
├── .p10k.zsh           ← Makes your prompt look fancy AF
├── .bashrc             ← Fallback for bash peasants (jk bash is cool too)
├── .oh-my-zsh/         ← Plugins to make life easier

📁 ~/.config/ Stuff
├── btop/               ← System monitor but make it ✨aesthetic✨
├── cava/               ← Audio visualizer (totally necessary)
├── fastfetch/          ← Flex your system specs
├── wal/                ← Color schemes from the gods
├── wlogout/            ← Logout menu (fancy exit strategy)

📁 Other Goodies
├── .fonts/             ← The secret sauce for icons
├── Wallpaper/          ← Eye candy collection
└── .script/            ← Install script (use at own risk)
```

---

## 🎯 Why Does This Exist?

**Great question!** Here's my deep philosophical reasoning:

1. **To make setting up a new Linux box easy:** Clone → Run → BAM! Instant drip 💧
2. **Flexing Rights** - So I can casually share screenshots and watch people ask "how did you do that?"
3. **Minimal but cool:** Less is more, but more is also more
4. **For fun:** Because life's too short for boring terminals (Vanilla terminals hurt my soul)
5. **To procrastinate:** Originally started this to avoid doing actual work
6. **Learning** - I wanted to understand dotfiles (mission accomplished? not yet)

---

## 🚀 Quick Install (The "I Trust You Bro" Method)

### Prerequisites (The Boring But Important Stuff)

Make sure you have:
- `zsh` (your new shell overlord)
- `git` (you're on GitHub, so... probably)
- `curl` or `wget` (for downloading all the things)
- Font utilities (because icons)
- **Powerlevel10k** (the star of the show)
- `btop`, `cava`, `fastfetch` (the supporting cast)
- `python3` + `pywal` (color magic generator)
- A terminal emulator that doesn't suck (Kitty, Alacritty, GNOME Terminal, etc.)
- *(Optional)* `wlogout` for the fancy logout menu
- **Most Important:** A sense of adventure and a backup of your home folder

---

### The Actual Installation

```bash
# Clone this bad boy
git clone https://github.com/NajElaoud/Linux-Dotfiles.git ~/linux-dotfiles

# Enter the danger zone
cd ~/linux-dotfiles

# Cross your fingers and run
bash .script/install.sh
```
### ⚠️ About That Installer...

The `install.sh` script is currently in the **"testing so it doesn't nuke my system"** phase. Coming soon! Until then, you can:
1. Manually symlink files (like a caveman)
2. Copy configs to their proper locations
3. Read the source and implement it yourself (nerd)
4. Wait for me to finish it at 2 AM (recommended)

(Translation: The install script is still in development. For now, you're tech support. Good luck! 🫡)

## 🛠️ Manual Setup (For the Brave Souls)

### 1. Shell Configuration
```bash
# Backup your old configs (seriously, do this)
cp ~/.zshrc ~/.zshrc.backup

# Symlink the new hotness
ln -sf ~/linux-dotfiles/.zshrc ~/.zshrc
ln -sf ~/linux-dotfiles/.p10k.zsh ~/.p10k.zsh
```

### 2. Install the Fonts
```bash
# Copy fonts to your system
cp -r ~/linux-dotfiles/.fonts/* ~/.local/share/fonts/
fc-cache -fv
```

### 3. Configure Your Apps
```bash
# Create config directories if they don't exist
mkdir -p ~/.config/{btop,cava,fastfetch,wal,wlogout}

# Symlink all the configs
ln -sf ~/linux-dotfiles/btop/* ~/.config/btop/
ln -sf ~/linux-dotfiles/cava/* ~/.config/cava/
ln -sf ~/linux-dotfiles/fastfetch/* ~/.config/fastfetch/
# ... you get the idea
```

### 4. Apply a Wallpaper + Color Scheme
```bash
# Let pywal work its magic
wal -i ~/linux-dotfiles/Wallpaper/your-favorite-wallpaper.jpg

# Or use the convenience script
bash ~/linux-dotfiles/.script/apply-wal.sh
```
---

## 🎮 How to Use This Thing

### Daily Shenanigans

1. **Changing Wallpapers & Colors**
   ```bash
   # Run the magic script
   bash .script/apply-wal.sh
   ```
   This will let you pick a wallpaper and generate a matching color scheme. Your terminal will look coordinated like it went to fashion school.

2. **Customizing Your Prompt**
   - Edit `.p10k.zsh` to add/remove segments
   - Want battery percentage? It's in there.
   - Want the current moon phase? ...maybe don't go that far.

3. **Adding More Wallpapers**
   - Drop them in `Wallpaper/`
   - Run `apply-wal.sh` again
   - Profit

4. **Tweaking Colors**
   - Check `wal/` for color palettes
   - Pywal generates them automatically
   - Mix and match until your eyes are happy
---

## 🎪 Success Indicators

You'll know it worked when:
- ✅ Your terminal looks like it costs money
- ✅ Friends ask "is that Linux?"
- ✅ You spend more time in terminal than your browser
- ✅ You've taken at least 5 screenshots
- ✅ You're reading this in a perfectly themed terminal

## 📸 Show It Off

When people ask *"How did you do that?"*, you have three options:

1. **The Cool Response:** "Oh, just some light dotfile configuration"
2. **The Honest Response:** "I copied configs from the internet at 2 AM"
3. **The Mysterious Response:** "Magic ✨" (then refuse to elaborate)

---
## 🎓 What I Learned

- Dotfiles are deeper than the Mariana Trench
- Symlinks are both powerful and terrifying
- You can spend infinite time customizing a terminal
- "Just one more tweak" is a lie
- Backups are not optional
- GitHub is judging my commit messages
---

## 🙏 Credits

- **Me** - For spending way too much time on this
- **Coffee** - For existing
- **Stack Overflow** - For being the real MVP
- **The 47 browser tabs** - You know which ones
- **The Linux community** - For making this possible and not judging (too hard)
---
## 🎬 Final Words (because you scrolled this far)
If your terminal now looks like it belongs on a hacker movie set, mission accomplished 😎
If it still looks like vanilla Linux, check your font settings, then blame me.
If you end up showing this setup to your friends and they ask “How did you do that?” — say: “Magic.”
Just don’t tell them it was hours of dot-file tweaking.

And remember: *"It's not procrastination, it's terminal optimization."*
Go forth and rice your Linux machine! 🚀

*P.S. - If you find this useful, give it a star ⭐ It won't make my terminal faster, but it'll make my day better!*



