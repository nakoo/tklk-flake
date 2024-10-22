{
  lib,
  stdenv,
  buildPythonPackage,
  certifi,
  fetchFromGitHub,
  pythonOlder,
  pkg-config,
  rustPlatform,
  libiconv,
  darwin,
}:

buildPythonPackage rec {
  pname = "wassima";
  version = "1.1.4";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "jawah";
    repo = pname;
    rev = version;
    hash = "sha256-gJkMp7w8MMzPX8Ml4K/ZTVVvUiUX/vPHjiKVSD14TMc=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-0g4+Phvd43RN1kMnUnggVz31sAGCBf/hecjh4tHnC7s=";
  };

  nativeBuildInputs =
    [
      pkg-config
    ]
    ++ (with rustPlatform; [
      cargoSetupHook
      maturinBuildHook
    ]);

  buildInputs =
    [
      libiconv
      certifi
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
    ];

  disabledTests = [
    "test_ctx_use_system_store"
  ];

  pythonImportsCheck = [ "wassima" ];

  meta = with lib; {
    description = "Access your OS root certificates with the atmost ease";
    homepage = "https://github.com/jawah/wassima";
    changelog = "https://github.com/jawah/wassima/blob/${version}/HISTORY.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
