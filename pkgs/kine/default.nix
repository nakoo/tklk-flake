{ lib, stdenv, buildGoModule, fetchFromGitHub, ...}:

buildGoModule rec {
  pname = "kine";
  version = "0.11.12";
  src = fetchFromGitHub {
    owner = "k3s-io";
    repo = "kine";
    rev = "v0.11.12";
    hash = "sha256-jT5q3/4JbwQZokWgsLHnzYp2xn21cwZlxba7T9vKxiM=";
  };
  vendorHash = "sha256-Vec3hH6W3loL+7rqRy0Cg99AP4NKBN1oMxVi8+/GBpo=";
  ldflags = [
    "-s"
    "-w"
    "-X github.com/k3s-io/kine/pkg/version.Version=v0.11.12"
    "-X github.com/k3s-io/kine/pkg/version.GitCommit=unknown"
    "-extldflags"
    "-static"
  ];
  env = {
    "CGO_CFLAGS" = "-DSQLITE_ENABLE_DBSTAT_VTAB=1 -DSQLITE_USE_ALLOCA=1";
  };
}
