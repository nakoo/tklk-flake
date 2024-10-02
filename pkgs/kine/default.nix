{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

buildGoModule rec {
  pname = "kine";
  version = "0.13.2";
  src = fetchFromGitHub {
    owner = "k3s-io";
    repo = "kine";
    rev = "v${version}";
    hash = "sha256-KMyO9zZvQFyRaMtQ/d2Zgg6pG1SFIYWkzZgSZIqhiOQ=";
  };
  vendorHash = "sha256-kbMwLNBPJwFbUSZdYiWWdIZM8fclHDnRnxTTIXTIuHU=";
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
