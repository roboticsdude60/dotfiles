#!/usr/bin/env fish
# Cache files are written into this folder on demand by config.fish.
# This script runs on `chezmoi apply` to clear cached shell init outputs (brew, atuin, zoxide).
rm -rf $__fish_config_dir/cached_init
mkdir -p $__fish_config_dir/cached_init
