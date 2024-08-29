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
}:

buildPythonPackage rec {
  pname = "jh2";
  version = "5.0.3";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "jawah";
    repo = "h2";
    rev = "v${version}";
    hash = "sha256-K2vZK5ZLd/1rIKdibhwJi6aXRUh/QOojZ5uH2PPMymQ=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-hvvAnahxpX7lukQrOr2O2Qpdc3Wqt4VaS2nOs1cz2JI=";
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
    [ libiconv ]
    ++ lib.optionals stdenv.isDarwin [
      # Darwin includes certifi as wassima doesn't yet suport wassima
      certifi
      darwin.apple_sdk.frameworks.Security
    ];

  nativeCheckInputs = [
    hypothesis
    pytest-mock
    pytest-xdist
    pytestCheckHook
  ];

  pythonImportsCheck = [ "jh2" ];

  meta = with lib; {
    description = "HTTP/2 State-Machine based protocol implementation";
    homepage = "https://h2.readthedocs.io";
    changelog = "https://github.com/jawah/h2/blob/${version}/CHANGELOG.rst";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
