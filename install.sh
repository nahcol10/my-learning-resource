#!/bin/bash
# install.sh — ble.sh setup for Fedora
# Usage: place this file and .bashrc in the same directory, then run:
#   bash install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASHRC_SRC="${SCRIPT_DIR}/.bashrc"

# ── sanity check ──────────────────────────────────────────────────────────────
if [[ ! -f "$BASHRC_SRC" ]]; then
  echo "✗ .bashrc not found next to install.sh (expected: ${BASHRC_SRC})"
  exit 1
fi

# ── dependencies ──────────────────────────────────────────────────────────────
echo "→ Installing dependencies (git, gawk, make)..."
sudo dnf install -y git gawk make

# ── ble.sh ────────────────────────────────────────────────────────────────────
echo "→ Cloning ble.sh..."
rm -rf /tmp/blesh
git clone --recursive --depth 1 --shallow-submodules \
  https://github.com/akinomyoga/ble.sh.git /tmp/blesh

echo "→ Building and installing ble.sh..."
make -C /tmp/blesh install PREFIX=~/.local

echo "→ Cleaning up build files..."
rm -rf /tmp/blesh

# ── .bashrc ───────────────────────────────────────────────────────────────────
BASHRC_DEST="$HOME/.bashrc"

if [[ -f "$BASHRC_DEST" ]] && [[ "$(realpath "$BASHRC_SRC")" != "$(realpath "$BASHRC_DEST")" ]]; then
  echo "→ Backing up existing .bashrc to ~/.bashrc.bak..."
  cp "$BASHRC_DEST" "${BASHRC_DEST}.bak"
fi

if [[ "$(realpath "$BASHRC_SRC")" == "$(realpath "$BASHRC_DEST")" ]]; then
  echo "→ .bashrc is already in place, skipping copy."
else
  echo "→ Applying new .bashrc..."
  cp "$BASHRC_SRC" "$BASHRC_DEST"
fi

# ── done ──────────────────────────────────────────────────────────────────────
echo ""
echo "✓ Done! Apply immediately:"
echo ""
echo "    source ~/.bashrc"
echo ""
echo "Key bindings:"
echo "  → or Ctrl+F   accept ghost suggestion"
echo "  Ctrl+R         fuzzy history search"
echo "  Tab            completion menu"