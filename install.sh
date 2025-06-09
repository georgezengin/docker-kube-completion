#!/bin/bash

set -e

TARGET_DIR="$HOME/.docker-kube-completion"
SOURCE_LINE="source \$HOME/.docker-kube-completion/completion.sh"

# Clone the repo if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
    echo "[+] Cloning repository..."
    git clone https://github.com/georgezengin/docker-kube-completion.git "$TARGET_DIR"
else
    echo "[*] Directory already exists. Updating..."
    cd "$TARGET_DIR" && git pull
fi

# Detect appropriate shell config file
if [[ -n "$BASH_VERSION" ]]; then
    SHELL_RC="$HOME/.bashrc"
elif [[ -n "$ZSH_VERSION" ]]; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.profile"
fi

# Add source line if not already present
if grep -Fxq "$SOURCE_LINE" "$SHELL_RC"; then
    echo "[*] Already sourced in $SHELL_RC"
else
    echo "[+] Adding source line to $SHELL_RC"
    echo "$SOURCE_LINE" >> "$SHELL_RC"
fi

echo "[✓] Installed. Run: source $SHELL_RC or restart your shell."
