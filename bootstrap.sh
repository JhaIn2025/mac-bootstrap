#!/bin/bash
set -e

echo "==> Checking Homebrew"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Installing Homebrew..."

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon / Intel 兼容处理
  if [[ -d "/opt/homebrew/bin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -d "/usr/local/bin" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "Homebrew already installed"
fi


echo "==> Checking Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  echo "Xcode Command Line Tools not found."
  xcode-select --install
  echo "Please finish Xcode CLI tools installation, then re-run this script."
  exit 1
fi

echo "==> Installing Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> Updating Homebrew"
brew update

echo "==> Installing core CLI tools"
brew bundle --file brew/Brewfile.core

echo "==> Installing language environments"
brew bundle --file brew/Brewfile.lang

echo "==> Installing GUI applications"
brew bundle --file brew/Brewfile.gui

echo "==> Initializing FVM"
if command -v fvm &>/dev/null; then
  mkdir -p "$HOME/.fvm"
fi

echo "==> Ensuring FVM is in PATH"
FVM_LINE='export PATH="$HOME/.fvm/default/bin:$PATH"'
ZSHRC="$HOME/.zshrc"

if ! grep -q 'fvm/default/bin' "$ZSHRC" 2>/dev/null; then
  echo "" >> "$ZSHRC"
  echo "# FVM" >> "$ZSHRC"
  echo "$FVM_LINE" >> "$ZSHRC"
fi

echo "==> Installing Flutter 3.22.2 via FVM"

FLUTTER_VERSION="3.22.2"

if command -v fvm &>/dev/null; then
  # 确保 fvm 目录存在
  mkdir -p "$HOME/.fvm"

  # 检查是否已安装该版本
  if ! fvm list | grep -q "$FLUTTER_VERSION"; then
    echo "Installing Flutter $FLUTTER_VERSION"
    fvm install "$FLUTTER_VERSION"
  else
    echo "Flutter $FLUTTER_VERSION already installed"
  fi

  # 设置为全局默认
  echo "Setting Flutter $FLUTTER_VERSION as global default"
  fvm global "$FLUTTER_VERSION"
else
  echo "WARNING: fvm not found, skipping Flutter installation"
fi

echo "==> Installing Android SDK tools"

ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT

if [ ! -d "$ANDROID_SDK_ROOT" ]; then
  mkdir -p "$ANDROID_SDK_ROOT"
fi

# 接受 licenses（重要）
yes | sdkmanager --licenses >/dev/null 2>&1 || true

# 基础工具
sdkmanager \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0"

echo "==> Bootstrap completed 🎉"
echo "You may want to restart your terminal or log out/in once."
