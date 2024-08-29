{ lib, stdenv, buildGoModule, fetchFromGitHub, ...}:

buildGoModule rec {
  name = "cilium-cni";
  version = "1.16.1";
  src = fetchFromGitHub {
    owner = "cilium";
    repo = "cilium";
    rev = "v${version}";
    hash = "sha256-vhnHCLIQEQTK/Uv3oPW49KZyDWQOKxgsrZRxh4yRZlg=";
  };
  vendorHash = null;
  sourceRoot = "source/plugins/cilium-cni";
}
