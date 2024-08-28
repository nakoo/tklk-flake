{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  isPyPy,

  # build-system
  hatchling,
  h11,
  jh2,
  qh3,
  urllib3,
  cacert,
  brotli,
  python-socks,

  # tests
  backports-zoneinfo,
  pytestCheckHook,
  pytest-timeout,
  pythonOlder,
  tornado,
  trustme,
  pytest-asyncio,
  pytest-socket,
}:

buildPythonPackage rec {
  pname = "urllib3-future";
  version = "2.8.905";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jawah";
    repo = "urllib3.future";
    rev = version;
    hash = "sha256-02aMNZoYx7PJ8yrxgsLzO8UitBg1+ezKduYjGf9ffkE=";
  };

  __darwinAllowLocalNetworking = true;
  dependencies = [
    hatchling
    h11
    jh2
    qh3
    python-socks
    brotli
    cacert
  ];
  buildInputs = [

  ];

  nativeCheckInputs = [
    pytest-asyncio
    pytest-timeout
    pytest-socket
    pytestCheckHook
    tornado
    trustme
  ];

  preCheck = ''
    export CI # Increases LONG_TIMEOUT
  '';

  checkPhase = ''
    # skip this test due to it requiring external network access
    # as well as a dep on ipv6, which test build might also not have
    pytest -k "not test_doh_rfc8484"
  '';

  pythonImportsCheck = [ "urllib3_future" ];

  meta = with lib; {
    description = "Powerful, user-friendly HTTP client for Python";
    homepage = "https://urllib3future.readthedocs.io/en/latest/";
    changelog = "https://github.com/jawah/urllib3.future/blob/${version}/CHANGES.rst";
    license = licenses.mit;
    maintainers = [ ];
  };
}
