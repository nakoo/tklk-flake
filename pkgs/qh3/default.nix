{
  lib,
  stdenv,
  buildPythonPackage,
  certifi,
  fetchFromGitHub,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  pythonOlder,
  pkg-config,
  rustPlatform,
  libiconv,
  darwin,
  hypothesis,
  cmake,
  ninja,
  cryptography,
  python,
  nasm,
}:

buildPythonPackage rec {
  pname = "qh3";
  version = "1.0.9";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "jawah";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-qpTdMCfHvPh4ks9VpUBnJR1bCM6jAb/3id+qP+Pz5fo=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
        "ls-qpack-sys-0.1.4" = "sha256-N4vSmLkkNKM1OW3NhvF4IBlSL6LMBbyV+08B09EbLR0=";
    };
  };
  nativeBuildInputs =
    [
      pkg-config
      cmake
      ninja
      nasm
    ]
    ++ (with rustPlatform; [
      cargoSetupHook maturinBuildHook
    ]);

  buildInputs = [libiconv cryptography] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  dontUseCmakeConfigure = true;

  pythonImportsCheck = [ "qh3" "qh3._hazmat" ];

  meta = with lib; {
    description = "HTTP/2 State-Machine based protocol implementation";
    homepage = "https://h2.readthedocs.io";
    changelog = "https://github.com/jawah/h2/blob/${version}/CHANGELOG.rst";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
