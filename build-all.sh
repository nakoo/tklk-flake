#!/bin/sh
set -e
echo "reset flake files if they've been modified"
# git checkout flake.nix
git checkout flake.lock
if [ $(uname -o) == "Darwin" ]; then
  echo "Use nixpkgs for macOS builds"
  sed -i '' 's/nixos-unstable/nixpkgs-unstable/g' flake.nix
  echo "building macOS specific packages first"
  nix build .#sublime4 --accept-flake-config
  nix build .#sublime4-dev --accept-flake-config
else
  echo "building linux-only builds first"
  nix build .#cilium-cni --accept-flake-config
  nix build .#bio-rd --accept-flake-config
  nix build .#nomad --accept-flake-config
  nix build .#nomad-driver-containerd --accept-flake-config
fi
echo "building all other packages"
nix build .#kine --accept-flake-config
nix build .#httpie --accept-flake-config
nix build .#grpcmd --accept-flake-config
nix build .#terraform --accept-flake-config
nix build .#vault --accept-flake-config
nix build .#nomad_1_8 --accept-flake-config
nix build .#consul --accept-flake-config
nix build .#boundary --accept-flake-config
nix build .#packer --accept-flake-config
nix build .#attic --accept-flake-config
nix build .#attic-client --accept-flake-config
nix build .#attic-server --accept-flake-config
nix build .#zerotierone --accept-flake-config
if [ $(uname -o) == "Darwin" ]; then
  echo "Reset flake.nix to nixos-unstable for linux builds"
  sed -i '' 's/nixpkgs-unstable/nixos-unstable/g' flake.nix
fi
attic push tklk result -j 2
