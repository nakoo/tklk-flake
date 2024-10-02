{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  nix-update,
  ...
}:

buildGoModule rec {
  pname = "tc-redirect-tap";
  version = "nightly-2024-07-27";
  src = fetchFromGitHub {
    owner = "awslabs";
    repo = "tc-redirect-tap";
    rev = "2db41f504194e5fa2b1451647c2154c0a840b02c";
    hash = "sha256-cGwYNwU3eKL2URPo5YjZ4j90Pz+thsd+zanvQ5+lJmg=";
  };
  subPackages = [
    "cmd/tc-redirect-tap"
  ];
  vendorHash = "sha256-MGGNYgHGyXKuIVNCaH60++bF72Glewfx4Eqgs27uvnE=";
  meta = with lib; {
    mainProgram = "tc-redirect-tap";
    homepage = "https://github.com/awslabs/tc-redirect-tap";
    description = "A CNI plugin that allows you to adapt pre-existing CNI plugins/configuration to a tap device";
    platforms = platforms.linux;
    license = licenses.asl20;
  };
}
