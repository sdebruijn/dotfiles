# Developer tools for the MacBook, taken from what was installed on the Pop!_OS laptop (2026-11-02).
#
# Install:
#   xcode-select --install
#   brew bundle --file ~/.dotfiles/Brewfile
#
# Then follow MACOS.md for the steps Homebrew can't do.
#
# Two sections. "Team" is what any developer needs to clone, build, run and ship the Ofload repos.
# "Personal" is my own shell, editor and workflow.

# ----------------------------------------------------------------------------------------------
# Team
# ----------------------------------------------------------------------------------------------

# Git and GitHub
brew "git"
brew "gh"

# Containers and cloud. The repos run in Docker and deploy to AWS.
cask "docker-desktop"
brew "awscli"
brew "kubernetes-cli"

# PHP 8.4, the version this laptop runs. shipment-api needs ^8.4.18.
# The repos run PHP in Docker, so the host has no ext-imagick. MACOS.md shows how to add it with pecl.
brew "php@8.4"
brew "composer" # depends on php (8.5). MACOS.md shows how to make 8.4 the default.

# Node 24. CI builds on Node 18, but Homebrew no longer ships it.
# Don't add formulae that depend on the unversioned "node" formula. Its links clash with node@24.
brew "node@24", link: true
brew "pnpm"
# Redocly CLI comes from npm (see MACOS.md). The formula depends on "node".

# Postgres client. qa-automation-cypress loads and dumps test data with psql and pg_dump.
# libpq is keg-only, so link it to get psql and pg_dump on PATH.
brew "libpq", link: true

# AI coding. The repos ship CLAUDE.md files.
cask "claude-code"

# Apps
cask "google-chrome"
cask "slack"

# ----------------------------------------------------------------------------------------------
# Personal
# ----------------------------------------------------------------------------------------------

# Shell and terminal
brew "starship"
brew "zoxide"
brew "fzf"
brew "tmux"
brew "tmuxp"
brew "zellij"
brew "stow"
cask "font-jetbrains-mono-nerd-font"

# Editors and IDEs
brew "neovim"
cask "jetbrains-toolbox" # install PhpStorm, WebStorm, DataGrip and IntelliJ IDEA CE from here

# Search and text
brew "ripgrep"
brew "ack"
brew "bat"
brew "tree"
brew "gawk"
brew "watch"

# JSON and YAML
brew "jq"
brew "yq"

# Linters
brew "shellcheck"
brew "yamllint"

# Database clients
brew "redis" # for redis-cli. The server only runs if you `brew services start redis`.

# Kubernetes
brew "stern"

# Browsers
cask "firefox"

# Notes
cask "obsidian"
cask "dropbox"
