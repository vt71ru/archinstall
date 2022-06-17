#!/usr/bin/env bash
sudo pacman -S --needed base-devel git wget yajl
mkdir /home/user/tmp
cd /home/user/tmp
git clone https://aur.archlinux.org/package-query.git
cd package-query/
makepkg -si
cd ..
git clone https://aur.archlinux.org/yaourt.git
cd yaourt/
makepkg -si
cd ..
sudo rm -dR yaourt/ package-query/
