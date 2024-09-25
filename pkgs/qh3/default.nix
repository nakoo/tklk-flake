{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  rustPlatform,
  libiconv,
  darwin,
  python,
  openssl,
  runCommand,
  cmake,
  ninja,
  pkg-config,
}:

buildPythonPackage rec {
  pname = "qh3";
  version = "1.1.0";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "jawah";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-I15V8lq0vo97PM9huhzSzBQFjM3IHygze87fcbDdGWY=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "ls-qpack-sys-0.1.4" = "sha256-N4vSmLkkNKM1OW3NhvF4IBlSL6LMBbyV+08B09EbLR0=";
      "ls-qpack-0.1.4" = "sha256-N4vSmLkkNKM1OW3NhvF4IBlSL6LMBbyV+08B09EbLR0=";
    };
  };

  dontUseCmakeConfigure = true;
  nativeBuildInputs =
    [
      cmake
      ninja
      pkg-config
    ]
    ++ (with rustPlatform; [
      bindgenHook
      cargoSetupHook
      maturinBuildHook
    ]);
  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isGNU [
      # Needed with GCC 12 but breaks on darwin (with clang)
      "-Wno-error=stringop-overflow"
    ]
  );

  buildInputs =
    [
      openssl
      libiconv
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  pythonImportsCheck = [ "qh3" ];

  meta = with lib; {
    description = "HTTP/2 State-Machine based protocol implementation";
    homepage = "https://h2.readthedocs.io";
    changelog = "https://github.com/jawah/qh3/blob/${version}/CHANGELOG.rst";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
