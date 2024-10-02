{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  nix-update,
  ...
}:

buildGoModule rec {
  pname = "cilium-cni";
  version = "1.16.2";
  src = fetchFromGitHub {
    owner = "cilium";
    repo = "cilium";
    rev = "v${version}";
    hash = "sha256-VOH79bvdDGkLT8VVTVIpyDtCd/jq4cYyM6De4Sm+QR8=";
  };
  vendorHash = null;
  sourceRoot = "source/plugins/cilium-cni";
  passthrough = {
    update-script = ''
      #!/usr/bin/env bash
      set -euo pipefail

      # Fetch the latest version via nix-update
      LATEST_VERSION=$(nix run github:Mic92/nix-update -- -F "$pname" --print-only)

      # Skip pre-releases (versions containing a hyphen, e.g., 1.2.3-alpha)
      if [[ "$LATEST_VERSION" =~ - ]]; then
        echo "Skipping pre-release version: $LATEST_VERSION"
        exit 0
      fi

      # Compare current version with the latest stable version
      if [[ "$LATEST_VERSION" > "$version" ]]; then
        echo "Newer version found: $LATEST_VERSION"
        nix run github:Mic92/nix-update -- -F "$pname" --build
      else
        echo "No update required. Current version ($version) is newer or equal."
      fi
    '';
  };
  meta = {
    platforms = lib.platforms.linux;
  };
}
