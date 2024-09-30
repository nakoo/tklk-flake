{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
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
  meta = {
    platforms = lib.platforms.linux;
  };
}
