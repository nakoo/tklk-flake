{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  nix-update,
  ...
}:

buildGoModule rec {
  pname = "goat";
  version = "nightly-2024-10-02";
  src = fetchFromGitHub {
    owner = "bluesky-social";
    repo = "indigo";
    rev = "00b60c68d71dc27e9f7dba2fb02dc93560a9f7f1"; # repo isn't tagged, so use commit refs
    hash = "sha256-cx0yrsAmQN/UoMdInziRitXZdpuae6qSKmPRNxS0ibs=";
  };
  vendorHash = "sha256-T+jtxubVKskrLGTUa4RI24o/WTSFCBk60HhyCFujPOI=";
  subPackages = [ "cmd/goat" ];
#   postInstall = ''
#     mkdir -p $out/bin
#     mv $out/bin/cni $out/bin/consul-cni
#   '';
}
