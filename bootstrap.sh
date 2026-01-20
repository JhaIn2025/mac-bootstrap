#!/bin/bash
set -e

echo "==> mac-bootstrap starting"

# 1. Xcode CLI tools
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools"
  xcode-select --install
  echo "Please finish Xcode CLI installation, then re-run."
  exit 1
fi

# 2. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -d "/opt/homebrew/bin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

brew update

# 3. Core tools
echo "==> Installing core CLI tools"
brew bundle --file brew/Brewfile.core

# 4. Language environments
echo "==> Installing language environments"
brew bundle --file brew/Brewfile.lang

# 5. GUI apps
echo "==> Installing GUI applications"
bash brew/install-gui.sh

echo "==> mac-bootstrap completed 🎉"
echo "Please log out/in or restart terminal once."
