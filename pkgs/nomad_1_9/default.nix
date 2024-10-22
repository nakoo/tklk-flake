# based heavily on nixpkgs nomad derivation
{
  lib,
  stdenv,
  buildGo123Module,
  fetchFromGitHub,
  installShellFiles,
  ...
}:

buildGo123Module rec {
  pname = "nomad";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "nomad";
    rev = "v1.9.0";
    hash = "";
  };

  vendorHash = "";

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

  meta = {
    license = lib.licenses.bsl11;
    mainProgram = "nomad";
  };

}
