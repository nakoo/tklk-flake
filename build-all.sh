#!/bin/bash
set -e

linux_packages=(
    "cilium-cni"
    "bio-rd"
    "nomad"
    "nomad-driver-containerd"
)

mac_packages=(
    "sublime4"
    "sublime4-dev"
)

common_packages=(
    "kine"
    "httpie"
    "grpcmd"
    "terraform"
    "vault"
    "nomad_1_8"
    "consul"
    "boundary"
    "packer"
    "attic"
    "attic-client"
    "attic-server"
    "zerotierone"
)

build_if_needed() {
    local package="$1"
    output=$(nix build ".#$package" --dry-run --print-out-paths --accept-flake-config 2>&1)
    if echo "$output" | grep -q "will be built:"; then
        echo "Package $package needs to be built. Building..."
        nix build ".#$package" --accept-flake-config
    else
        echo "Package $package is already built and available in the cache. Skipping."
    fi
}

echo "Reset flake files if they've been modified"
git checkout flake.nix
git checkout flake.lock

if [ "$(uname -s)" == "Darwin" ]; then
    echo "Use nixpkgs for macOS packages"
    sed -i '' 's/nixos-unstable/nixpkgs-unstable/g' flake.nix
    echo "Building mac-only packages"
    for package in "${mac_packages[@]}"; do
        build_if_needed "$package"
    done
else
    echo "Building linux-only packages"
    for package in "${linux_packages[@]}"; do
        build_if_needed "$package"
    done
fi

echo "Building common packages"
for package in "${common_packages[@]}"; do
    build_if_needed "$package"
done

if [ "$(uname -s)" == "Darwin" ]; then
    echo "Reset flake.nix to nixos-unstable for Linux builds"
    sed -i '' 's/nixpkgs-unstable/nixos-unstable/g' flake.nix
fi
