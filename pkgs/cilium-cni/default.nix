{ lib, stdenv, buildGoModule, fetchFromGitHub, ...}:

buildGoModule rec {
  name = "cilium-cni";
  version = "1.16.1";
  src = pkgs.fetchFromGitHub {
    owner = "cilium";
    repo = "cilium";
    rev = "v1.16.1";
    hash = "sha256-vhnHCLIQEQTK/Uv3oPW49KZyDWQOKxgsrZRxh4yRZlg=";
  };
  vendorHash = null;
  sourceRoot = "source/plugins/cilium-cni";
}
