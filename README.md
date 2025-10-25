# Linux-Dotfiles 🐧✨  
*AKA “Yes I spent too much time making my terminal look cool”*

## What is this sorcery?

This repo lives at: `https://github.com/NajElaoud/Linux-Dotfiles`  
It’s a carefully curated set of dotfiles, configs and wallpapers so that your Linux machine (or mine) doesn’t look like a boring “just another Ubuntu terminal”.

With this you get  
- zsh with fancy prompt (Powerlevel10k)  
- Nerd/Powerline patched fonts so icons don’t go “□”  
- Terminal status tools like btop, cava, fastfetch  
- Color-theme generator via pywal  
- A logout menu if you feel fancy (via wlogout)  
- Wallpapers, fonts, scripts, and more structure than my sock drawer.

In short: clone this, run the installer (or symlink manually), and you instantly have a laptop that says “I care about how my terminal looks”.

---

## Repo Layout (so you don’t angrily grep through everything)

- .zshrc ← main shell config
- .p10k.zsh ← Powerlevel10k prompt config
- .bashrc ← fallback for bash users
- .oh-my-zsh/ ← extra plugins/themes (yes, included)
- .fonts/ ← fonts that make your prompt icons work
- btop/ ← config for btop
- cava/ ← config for cava
- fastfetch/ ← custom fastfetch theme
- wal/ ← pywal palettes + wallpaper presets
- wlogout/ ← logout menu theme
- Wallpaper/ ← wallpapers. Your desktop deserves better.
- .script/ ← bootstrap / helper scripts

---

## Why did I build this? (besides procrastinating)

- To **make setting up a new Linux box easy**: clone → run → BAM, stylish terminal.  
- To **use symlinks** so I can keep everything version-controlled (yes, I version control my fonts).  
- To **make something minimal but cool**: less fluff, more prompt.  
- To **have fun**. Because life’s too short for vanilla shell.

---

## Prerequisites (the boring but essential bits)

Before you install, make sure your system has:

- `zsh`, `git`, `curl` (or `wget`), font utilities  
- Powerlevel10k installed (or install via oh-my-zsh custom themes)  
- `btop`, `cava`, `fastfetch`, `python3` + pywal  (ypu can use `pipx` too)
- A terminal emulator that supports Nerd/Powerline fonts (Kitty, Alacritty, GNOME Terminal etc)  
- (Optional) `wlogout` if you use X11/Wayland and want a logout menu  

---

## Quick Install (the “I trust you” mode)

```bash
git clone https://github.com/NajElaoud/Linux-Dotfiles.git ~/linux-dotfiles
cd ~/linux-dotfiles
bash .script/install.sh

If .script/install.sh doesn’t exist: don’t worry — jump to Manual Setup below.
```

## Manual Setup (the “I like control” mode)
```bash
I am still working on this part
```

---
## Prompt & Shell Stuff
- .zshrc expects oh-my-zsh or a similar framework. If you’re not using one, you might need to adapt.
- .p10k.zsh is the Powerlevel10k config — it shows time, git status, battery, CPU, etc.
  Make sure your terminal’s font is set to one of the patched fonts from .fonts/, otherwise you’ll see weird boxes instead of icons.
---
## Recipes & Tools
- btop: nice system monitor alternative to htop. Config under btop/.
- cava: terminal audio visualizer. Config under cava/.
- fastfetch: lightweight system info. Config in fastfetch/.
- pywal: run wal -i /path/to/Wallpaper/yourimage.jpg to generate a color scheme. Palettes stored in wal/.
- wlogout: if you use a standalone compositor/WM, use the custom theme in wlogout/.
---
## Wallpapers & Themes
- Wallpapers are in Wallpaper/. Choose one or replace them with your own.
- Run apply-wal.sh (in .script/) to apply a wallpaper and regenerate your color-scheme via pywal so your terminal + prompt match.
- Want to swap prompt style? Edit .p10k.zsh. There are commented segments to toggle.
- Customization (because you’re cool)
- Replace Wallpapers and re-run apply-wal.sh.
- Edit .p10k.zsh segments: comment/uncomment to add/remove icons & status blocks.
- Add or remove oh-my-zsh plugins by editing .oh-my-zsh/plugins/ (yes, included).
- Add more wal palettes if you like.
---
## Final Words (because you scrolled this far)
If your terminal now looks like it belongs on a hacker movie set, mission accomplished 😎
If it still looks like vanilla Linux, check your font settings, then blame me.
If you end up showing this setup to your friends and they ask “How did you do that?” — say: “Magic.”
Just don’t tell them it was hours of dot-file tweaking.

Go forth and rice your Linux machine! 🚀
— Najd



