#!/bin/bash

# script to set random background wallpapers on my GNOME desktop
# set base path
export wallpaper_path=/home/LoOtGobLiN/Pictures/Wallpaper
shopt -s nullglob

# store all the image file names in wallpapers array
wallpaper=(
    "$wallpaper_path"/*.jpg
    "$wallpaper_path"/*.jpeg
    "$wallpaper_path"/*.png
    "$wallpaper_path"/*.bmp
    "$wallpaper_path"/*.svg
)
# get array length
wallpaper_size=${#wallpaper[*]}

# set wallpapers in incremental order
index=0
while [ $index -lt $wallpaper_size ]
do
    gsettings set org.gnome.desktop.background picture-uri "${wallpaper[$index]}"
    wal -i "${wallpaper[$index]}"
    # index is maxing out, so reset it
    if [ $(($index+1)) -eq $wallpaper_size ]
    then
        index=0
    else
        index=$(($index + 1))
    fi
    # keep the wallpaper for the specified time
    sleep 5m
done
