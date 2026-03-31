# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a dotfiles management repo for bash configuration. It supports multiple environment profiles (home, work, etc.) with a common base, and auto-syncs changes to git on shell exit.

## Architecture

### Profile System

- `profiles/common/` — always loaded for every environment
- `profiles/active/` — a symlink to the currently selected profile (e.g., `profiles/home/`)
- `profiles/<name>/` — environment-specific profiles (home, attain, linkedin, etc.)
- `profiles/active` and `safety-zone/*` are gitignored

Scripts inside `profiles/common/` and `profiles/active/` are loaded in lexicographic order by the `profiles/common/profile` entrypoint. Only files matching the pattern `[0-9]{2}_*.sh` are sourced automatically. Helpers scripts are not auto-sourced — they are added to `$PATH` instead.

### Loading Order (profile entrypoint: `profiles/common/profile`)

1. Sources `~/.bashrc` (which sets `DOTFILES_BASEDIR`)
2. Pulls latest dotfiles from git
3. Sources all `[0-9]{2}_*.sh` scripts from `profiles/common/` then `profiles/active/`
4. Sources `profiles/active/profile.sh` if present
5. Sources helper utilities (`profile_utils.sh`, `xbar_utils.sh`)

### Key Files

- `profiles/common/profile` — main entrypoint, symlinked to `~/.profile`
- `profiles/common/00_utils.sh` — utility functions (`install`, `warn`, `get_os`, `get_package_manager`)
- `profiles/common/00_retcodes.sh` — named return codes (`GOOD`, `FILE_NOT_FOUND`, `PARAMETER_NOT_PROVIDED`)
- `profiles/common/00_safety-zone.sh` — `get_safe_value`/`set_safe_value` for reading `safety-zone/safety-zone_values.ini`
- `profiles/common/helpers/profile_utils.sh` — `switch_profile`, `select_profile`, `new_profile`
- `setup/links.csv` — defines symlinks created by setup (source relative to repo root → destination relative to `$HOME`)

### Safety Zone

Sensitive values (API keys, tokens) are stored in `safety-zone/safety-zone_values.ini` (gitignored). Access them in scripts via `get_safe_value KEY_NAME`. Set them via `set_safe_value KEY_NAME value`.

### Auto-commit on Exit

When `DOTFILES_COMMIT=true` (the default), an `EXIT` trap in `profiles/common/profile` runs `git add . && git commit && git push` on shell exit if there are uncommitted changes.

## Setup & Management

**Initial setup** (on a new machine):
```bash
bash setup/setup.sh [-b] [-d DEST_DIR] [-p PROFILE] [-y]
```

**Switch active profile:**
```bash
switch_profile <profile_name>   # interactive if no arg given
```

**Create a new profile:**
```bash
new_profile <profile_name>      # creates profiles/<profile_name>/
```

**Uninstall:**
```bash
bash setup/uninstall.sh [-d | -r]
```

**Disable auto-commit for a session:**
```bash
export DOTFILES_COMMIT=false
```

## Adding New Scripts

- Place auto-loaded scripts in `profiles/common/` or `profiles/<name>/` with a `NN_` numeric prefix
- Place helper scripts (added to PATH) in `profiles/common/helpers/` or `profiles/<name>/helpers/`
- Add new symlinks by editing `setup/links.csv`
- Add new profile-specific git config by placing a `gitconfig.*` file in `profiles/<name>/git/`

### Script numbering conventions
- `00_` — core utils, retcodes, safety-zone
- `01_` — environment variables
- `02_` — SSH/GCP agent setup
- `20_` — package manager (homebrew)
- `96_` — git config
- `97_` — bash completions
- `98_` — aliases
- `99_` — language finalization (java, pip3, kubectl)

## Symlinks (defined in setup/links.csv)

| Repo source | Home destination |
|---|---|
| `profiles/common/profile` | `~/.profile` |
| `profiles/common/vim/vimrc` | `~/.vimrc` |
| `profiles/common/vim/plugins.vim` | `~/.vim/plugins.vim` |
| `profiles/common/vim/plugin` | `~/.vim/plugin` |
| `profiles/common/vim/autoload` | `~/.vim/autoload` |
| `profiles/common/nvim/init.vim` | `~/.config/nvim/init.vim` |
| `profiles/common/linters/flake8` | `~/.flake8` |
| `profiles/common/linters/yamllint` | `~/.yamllint` |
| `profiles/active/git/gitignore` | `~/.gitignore` |

## Vim/Neovim Config Layering

- **`profiles/common/vim/vimrc`** (symlinked to `~/.vimrc`) — main vim config; sources `~/.vim/plugins.vim`, then `profiles/active/vimrc`, then `profiles/active/vim/plugin/*.vim`
- **`profiles/common/vim/plugins.vim`** (symlinked to `~/.vim/plugins.vim`) — vim-plug setup; common plugins for all profiles; auto-installs missing plugins on VimEnter
- **`profiles/<name>/vim/plugins.vim`** — profile-specific plugin additions
- **`profiles/<name>/vimrc`** — profile-specific vim/nvim settings (sourced by the common vimrc)
- **`profiles/common/nvim/init.vim`** (symlinked to `~/.config/nvim/init.vim`) — sources `~/.vimrc`, then `profiles/active/nvim/*.vim`

### Where to edit for specific changes

| What to change | File to edit |
|---|---|
| Vim setting for all profiles | `profiles/common/vim/vimrc` |
| Vim plugin for all profiles | `profiles/common/vim/plugins.vim` |
| Vim setting for one profile | `profiles/<name>/vimrc` |
| Vim plugin for one profile | `profiles/<name>/vim/plugins.vim` |
| Neovim-only setting (all profiles) | `profiles/common/nvim/init.vim` |
| Neovim colorscheme (profile-specific) | `profiles/<name>/vimrc` (lua `vim.cmd("colorscheme ...")` in UIEnter autocmd) |
| Bash for all profiles | `profiles/common/NN_name.sh` |
| Bash for one profile | `profiles/<name>/NN_name.sh` |
| Secrets/tokens | `safety-zone/safety-zone_values.ini` via `get_safe_value`/`set_safe_value` |
