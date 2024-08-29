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
  version = "1.1.1";
  pyproject = true;

  disabled = pythonOlder "3.7";

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-HSYEqECwlXrPrSIBYx7i+pV6B5QTAR+RFbybEELo2SM=";
  };

  src = fetchFromGitHub {
    owner = "jawah";
    repo = pname;
    rev = version;
    hash = "sha256-bfwDau2PwmvZHjIsUmNjNs2h0+bsnHpb1qV2Lv6v4b0=";
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
