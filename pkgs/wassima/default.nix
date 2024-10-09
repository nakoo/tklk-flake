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
  version = "1.1.3";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "jawah";
    repo = pname;
    rev = version;
    hash = "sha256-zOg8KoHvoBKaUYMxhd/MxT7cJazHrCr5PEfChyg9WzM=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-oC55yJ57tJyTEAIfMnb87zreitg37dRJFj6nVamf9cU=";
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
