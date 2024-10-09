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
  version = "nightly-2024-10-09";
  src = fetchFromGitHub {
    owner = "bluesky-social";
    repo = "indigo";
    rev = "06bacb465af714feb77609566aba15ab1ed41e24"; # repo isn't tagged, so use commit refs
    hash = "sha256-wWsE3sAGZQmOBVqTgy4RjoU8zmtuvyQIj9DjwSbtmKw=";
  };
  vendorHash = "sha256-T+jtxubVKskrLGTUa4RI24o/WTSFCBk60HhyCFujPOI=";
  subPackages = [ "cmd/goat" ];
}
