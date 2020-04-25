#!/usr/bin/env sh


i3-msg "workspace 1:Eternal_Families; append_layout ~/.dotfiles/custom_scripts/relC200i3layout.json"


# and then start polar bookshelf
~/.local/bin/polar-bookshelf-1.100.13-x64/polar-bookshelf&

# and JoplinDesktop
JoplinDesktop.AppImage&
