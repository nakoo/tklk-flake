#!/bin/bash
set -e

if [ "$(uname -s)" == "Darwin" ]; then
    echo "Use nixpkgs for macOS packages"
    sed -i '' 's/nixos-unstable/nixpkgs-unstable/g' flake.nix
fi

nix run .#push-packages

if [ "$(uname -s)" == "Darwin" ]; then
    echo "Reset flake.nix to nixos-unstable for Linux builds"
    sed -i '' 's/nixpkgs-unstable/nixos-unstable/g' flake.nix
fi
