{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

buildGoModule rec {
  pname = "bio-rd";
  version = "0.1.9+nightly";
  src = fetchFromGitHub {
    owner = "bio-routing";
    repo = "bio-rd";
    rev = "53c49e38000ef23d586af40e417fb0ec65a0a17e";
    hash = "sha256-1JJstVsFeL//N5aPk2vKpPh/LlTiQfYefJmo+Ahyfu8=";
  };
  vendorHash = "sha256-gnlJCVhzBkbadN9YQvlWMreOidUFHCwXiH6KpISNDXE=";
  subPackages = [
    "cmd/bio-rd"
    "cmd/bio-rdc"
    "cmd/ris-lg"
    "cmd/ris-mirror"
    "cmd/ris"
    "cmd/riscli"
  ];
  ldflags = [
    "-s"
    "-w"
  ];
}
