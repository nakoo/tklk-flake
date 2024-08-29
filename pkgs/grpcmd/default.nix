{
  lib,
  stdenv,
  buildGo123Module,
  fetchFromGitHub,
  ...
}:

buildGo123Module rec {
  pname = "grpcmd";
  version = "0.2.1";
  src = fetchFromGitHub {
    owner = "grpcmd";
    repo = "grpcmd";
    rev = "v${version}";
    hash = "sha256-7dh0fTdwYBTXURKYkBRlodj31wxW1n9VTGje9ggnvt4=";
  };
  vendorHash = "sha256-Yly46Xq9d/B0v3A+WUUKCQmvybN4z3KvstAfC7/TYv8=";
  meta = {
    description = "A simple, easy-to-use, and developer-friendly CLI tool for gRPC";
    homepage = "https://grpc.md/";
    license = lib.licenses.mit;
    mainProgram = "grpc";
  };
}
