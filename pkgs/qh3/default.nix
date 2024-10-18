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
  version = "1.2.1";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "jawah";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Skg87JhFFTuuL03XdSEpnooQ/sKOzSEqflcCaFKvRZo=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "ls-qpack-0.1.4" = "sha256-RiEQX5wNs2oAMnKFAoNR4GaV6jYxoUiRHw9/AUJ3NTc=";
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
