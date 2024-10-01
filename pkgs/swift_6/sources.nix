{ lib, fetchFromGitHub }:

let

  # These packages are all part of the Swift toolchain, and have a single
  # upstream version that should match. We also list the hashes here so a basic
  # version upgrade touches only this file.
  version = "6.0";
  hashes = {
    llvm-project = "sha256-P0IEyQLcMkaL7lGOxq2GOQXn8q0pCsnW06RB4Lrq0io=";
    sourcekit-lsp = "sha256-XDGq64LbpgBrRy3IvZNgsoLUePXECK5p10vQ8cUKeGE=";
    swift_6 = "sha256-NdIr/auUw9nY+NLii4iH0biA++9n10mrRpBtKYYEJ3k=";
    swift-cmark = "sha256-b/igbZbHFXK/SqS84UGWsUoVjChNFBb0t0w4HoPTguE=";
    swift-corelibs-foundation = "sha256-yRjjxJRy1eTM9VG7/Fn60UMghPavsaoueH0V8cjaIyM=";
    swift-corelibs-libdispatch = "sha256-XOAWuaGqWJtxhGIPXYT3PIvk5OK0rkY4g1IOybJUlm4=";
    swift-corelibs-xctest = "sha256-99mEGgJF3zagFBNbPH1QeltTjqkdsfJYix14LWSKw1Q=";
    swift-docc = "sha256-k1ygYDZwF4Jo7iOkHxc/3NzfgN+8XNCks5aizxBgPjM=";
    swift-docc-render-artifact = "sha256-vdSyICXOjlNSjZXzPRxa/5305pg6PG4xww9GYEV9m10=";
    swift-driver = "sha256-AqvR6Sk3ifUvpTMmEL4e+1RWWewlZyceJhRZShWhOcc=";
    swift-experimental-string-processing = "sha256-lK/teda9uti2vRSOBHY0OklnEsrv46RYnlw5/qNDl5w=";
    swift-format = "sha256-uKhIcbJb0DDHKACfVrhQ4fSyXVUkAj090eUZsOrtEqw=";
    swift-package-manager = "sha256-OleB9+funouJAs/9uEp/z/NHF4asPLRugcMQ5O+DJJM=";
    swift-syntax = "sha256-bpv8FjgRXt6dNw7Ys46V7VoT04ASG7uQbQAPJWZZd1M=";
  };

  # Create fetch derivations.
  sources = lib.mapAttrs (repo: hash: fetchFromGitHub {
    owner = "swiftlang";
    # inherit repo;
    repo = if repo == "swift_6" then "swift" else repo;
    rev = "swift-${version}-RELEASE";
    name = "${repo}-${version}-src";
    hash = hashes.${repo};
  }) hashes;

in sources // { inherit version; }
