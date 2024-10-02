{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  nix-update,
  ...
}:

buildGoModule rec {
  pname = "consul-cni";
  version = "1.5.3+nightly";
  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "consul-k8s";
    rev = "aacc8c78f5d3afb98a1948930ff9e275ed31ca95";
    hash = "sha256-jGFi6S7r/OmkuX+snhnjhXN7lQEas7L4DVGXu46LQRw=";
  };
  vendorHash = "sha256-jqH/39e2PHUzG1h88yXw3EpIVW9aYJPFU0VADKujLNk=";
  sourceRoot = "source/control-plane/cni";
  postInstall = ''
    mkdir -p $out/bin
    mv $out/bin/cni $out/bin/consul-cni
  '';
  passthrough = {
    update-script = ''
      #!/usr/bin/env bash
      set -euo pipefail
      # skipping updates
      exit 0
    '';
  };
  meta = {
    platforms = lib.platforms.linux;
  };
}
