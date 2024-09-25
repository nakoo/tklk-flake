{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

buildGoModule rec {
  pname = "kine";
  version = "0.13.0";
  src = fetchFromGitHub {
    owner = "k3s-io";
    repo = "kine";
    rev = "v${version}";
    hash = "sha256-2+XTuqAiwGJDatuLvlczqz2/VRetPWZ8dcRT8REs794=";
  };
  vendorHash = "sha256-Vec3hH6W3loL+7rqRy0Cg99AP4NKBN1oMxVi8+/GBpo=";
  ldflags = [
    "-s"
    "-w"
    "-X github.com/k3s-io/kine/pkg/version.Version=v${version}"
    "-X github.com/k3s-io/kine/pkg/version.GitCommit=unknown"
  ];
  doCheck = false;
  env = {
    "CGO_CFLAGS" = "-DSQLITE_ENABLE_DBSTAT_VTAB=1 -DSQLITE_USE_ALLOCA=1";
  };
}
