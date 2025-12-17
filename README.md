# 🍚 Linux Dotfiles 🥢

![Status: Rice Achieved](https://img.shields.io/badge/status-rice%20achieved-10B981)
![Productivity: Questionable](https://img.shields.io/badge/productivity-questionable-F59E0B)
![Works on My Machine](https://img.shields.io/badge/Works%20on-My%20Machine-059669)
![Hours Wasted](https://img.shields.io/badge/Hours%20Wasted-Too%20Many-DC2626)
![Commit Count](https://img.shields.io/badge/Commits-Way%20Too%20Many-D97706)
[![Installer: Actually Works](https://img.shields.io/badge/Installer-Actually%20Works-00D9FF)](https://github.com/NajElaoud/Linux-Dotfiles)

> *"Configuring dotfiles is just adult Legos with more existential dread"*

My Linux rice. First attempt. It works on my machine. Probably works on yours too, but who knows.

This started because I was bored on a Tuesday and spiraled into a multi-hour terminal customization session. Now you can benefit from my poor impulse control.

---

## 🚀 Installation

**The Lazy Way (Recommended):**
```bash
git clone https://github.com/NajElaoud/Linux-Dotfiles.git ~/linux-dotfiles
cd ~/linux-dotfiles
chmod +x .script/install.sh
./.script/install.sh
```

The installer will:
- Auto-detect your distro and install dependencies (unless you’re running something that makes me question your life choices)
- Back up your current configs (because we all know future you will not thank past you)
- Install Oh My Zsh + Powerlevel10k (making your prompt look way too sexy for your own good)
- Install Nerd Fonts (because your terminal shouldn’t look like it’s having a stroke)
- Symlink all configs (so you can act like you know what you’re doing)
- Change your shell to zsh
- Roast your life decisions as it runs (because why not)

**Supported distros:** Arch, Ubuntu/Debian, Fedora. If you're running Gentoo, you already know what you're doing, so just go back to compiling everything by hand.

**The installer has 5 hidden easter eggs.** They're actually funny, unlike most easter eggs that are just "wow you found me." Good luck wasting time finding them.

---

## 📦 What You Get

**Core:**
- **zsh + Oh My Zsh** - Your new shell overlord
- **Powerlevel10k** - Makes your prompt look unfairly good
- **Nerd Fonts** - For when you need 47 different arrow icons

**Optional (installer asks):**
- **btop** - htop but it looks like it’s actually trying to be useful
- **cava** - Audio visualizer (because staring at CPU graphs gets old)
- **fastfetch** - System info flex tool
- **pywal** - Auto color schemes based on wallpapers (because your terminal needs a theme, not a personality)
- **variety** - Wallpaper changer (pre-configured to trigger pywal automatically, because you’re lazy)

**Included:**
- Wallpapers (in `Pictures/`)
- Modified Variety config (changes wallpaper → triggers pywal → your terminal matches automatically)
- Custom configs for everything
- My taste in aesthetics (no refunds)

---

## 🛠️ Manual Install (If You Hate Convenience)

**1. Install shit:**
```bash
# Arch
sudo pacman -Sy git zsh curl btop cava fastfetch python-pywal

# Ubuntu/Debian  
sudo apt install git zsh curl btop cava fastfetch python3-pywal

# Fedora
sudo dnf install git zsh curl btop cava fastfetch python3-pywal
```

**2. Oh My Zsh:**
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

**3. Powerlevel10k:**
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

**4. Fonts:**
```bash
cp -r ~/linux-dotfiles/.fonts/* ~/.local/share/fonts/
fc-cache -fv
```

**5. Symlink everything:**
```bash
ln -sf ~/linux-dotfiles/.zshrc ~/.zshrc
ln -sf ~/linux-dotfiles/.p10k.zsh ~/.p10k.zsh
mkdir -p ~/.config/{btop,cava,fastfetch,wal,wlogout}
ln -sf ~/linux-dotfiles/.config/btop/* ~/.config/btop/
ln -sf ~/linux-dotfiles/.config/cava/* ~/.config/cava/
ln -sf ~/linux-dotfiles/.config/fastfetch/* ~/.config/fastfetch/
```

**6. Change shell:**
```bash
chsh -s $(which zsh)
```

Logout. Login. Done.

---

## 🎨 Post-Install

**Configure your prompt:**
```bash
p10k configure
```
Pick whatever makes you feel like a hacker.

**Apply a wallpaper + color scheme:**
```bash
wal -i ~/linux-dotfiles/Pictures/whatever.jpg
```

**Or use Variety for automatic wallpaper rotation:**
```bash
variety
```
Variety is pre-configured to automatically trigger pywal when it changes wallpapers. Set it to change every X minutes and your terminal will stay color-matched without you lifting a finger. Peak laziness achieved.

**Test everything:**
```bash
fastfetch  # Show off
btop       # Pretend to monitor your system
cava       # Make it look like you’re "visualizing" something with music
```

Add more wallpapers to `Pictures/` and let pywal work its magic. You'll get bored in 20 minutes anyway.

**Pro tip:** Variety auto-rotates wallpapers and updates terminal colors. It’s like having a minion manage your aesthetics while you pretend to work.

---

## 🔧 When Shit Breaks

**Fonts showing □□□:**
```bash
fc-cache -fv
# Restart terminal
```

**Powerlevel10k not working:**
```bash
p10k configure
```

**Colors fucked:**
```bash
wal -i ~/linux-dotfiles/Pictures/some-image.jpg
```

**Need to restore old configs:**
```bash
ls ~ | grep dotfiles_backup  # Find your backup
cp ~/.dotfiles_backup_TIMESTAMP/.zshrc ~/.zshrc
```

**Installer failed halfway:**
Just run it again. It skips completed steps.

**Shell didn't change:**
```bash
chsh -s $(which zsh)
# Logout/login
```

---

## 📂 Repository Structure

```
~/linux-dotfiles/
├── .config/           # App configs (btop, cava, fastfetch, variety, etc.)
├── .fonts/            # Nerd Fonts
├── .script/           # The installer (+ 5 easter eggs)
├── Pictures/          # Wallpapers
├── .zshrc             # Zsh config
├── .p10k.zsh          # Powerlevel10k config
└── .bashrc            # Bash fallback (for the nostalgic)
```

**Note:** The Variety config is modified to run `wal -i` on wallpaper change. This means your terminal colors auto-update every time Variety switches wallpapers. Set it and forget it.

---

## 🎯 Success Checklist

- [ ] Your terminal doesn't look like a crime scene from 2003
- [ ] Icons render properly (no more boxes of shame)
- [ ] You've spent 2+ hours tweaking colors instead of doing actual work
- [ ] Screenshot folder growing faster than your commit history
- [ ] You've explained your setup to someone who didn't ask

If all checked: Congratulations, you're one of us now. There’s no going back to the default terminal. Ever.

---

## ⚠️ Disclaimer

This is my first rice. First time touching dotfiles. First GitHub upload in this category. I learned everything from YouTube tutorials and late-night Stack Overflow sessions.

**I am not responsible if:**
- Your system decides to commit sudoku
- You accidentally nuke your home directory because you weren't paying attention
- Your productivity drops harder than your motivation on Mondays
- You start judging people based on their terminal setup

**Backups are created automatically.** But seriously, use Timeshift or something. Trust me on this one. We don't talk about that time I didn’t.

---

## 📜 License

MIT - Do whatever. Break it, improve it, sell it to NFT enthusiasts. I don't care.

If it works: You're welcome.  
If it breaks: Skill issue.  
If you get featured on r/unixporn: Send screenshots.

---

## 🙏 Credits

- **Me** - For wasting hours I'll never get back making this instead of finishing actual projects
- **Coffee** - Without which none of this would exist
- **Oh My Zsh & Powerlevel10k teams** - For doing the actual hard work so I don't have to
- **Stack Overflow** - My real university education
- **That one YouTube tutorial** - You know which one
- **You** - For actually reading this far instead of just running the installer

---

## 💀 Final Thoughts

This setup makes your terminal look professional. It won’t make you a better programmer. It won’t solve your imposter syndrome. It won’t clean up your spaghetti code.
But it will make you feel productive while you’re actually just staring at your terminal, waiting for something to break.
Now go forth and spend your entire afternoon tweaking transparency values.

**Star the repo if this destroyed your productivity.** ⭐

---

**P.S.** - If you find all 5 easter eggs in the installer, you win... nothing. But you'll know. And that's what matters.
