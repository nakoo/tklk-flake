# based heavily on nixpkgs nomad derivation
{
  lib,
  stdenv,
  buildGo123Module,
  fetchFromGitHub,
  installShellFiles,
  nix-update,
  semver-tool,
  ...
}:

buildGo123Module rec {
  pname = "nomad";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "nomad";
    rev = "v1.9.0-beta.2";
    hash = "sha256-aAKxGp3bxbvpnl41MquT7A+T61ooJcWnry81P7JiPm4=";
  };

  vendorHash = "sha256-Ss/qwQ14VUu40nXaIgTfNuj95ekTTVrY+zcStFDSCyI=";

  subPackages = [ "." ];

  nativeBuildInputs = [ installShellFiles ];

  tags = [ "ui" ];

  preCheck = ''
    export PATH="$PATH:$NIX_BUILD_TOP/go/bin"
  '';

  postInstall = ''
    echo "complete -C $out/bin/nomad nomad" > nomad.bash
    installShellCompletion nomad.bash
  '';

  buildInputs = [ nix-update semver-tool ];

  meta = {
    license = lib.licenses.bsl11;
    mainProgram = "nomad";
  };

}
