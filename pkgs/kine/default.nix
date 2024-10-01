{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

buildGoModule rec {
  pname = "kine";
  version = "0.13.1";
  src = fetchFromGitHub {
    owner = "k3s-io";
    repo = "kine";
    rev = "v${version}";
    hash = "sha256-krBeNuEoDseqzSSqgRMNuvetbvZJYttcg0C/4uA3/uA=";
  };
  vendorHash = "sha256-QvexsR27CTcqvkbLLlp5/TNMV5cqVTScMHhcljZzhTI=";
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
