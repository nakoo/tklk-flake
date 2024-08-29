{
  lib,
  stdenv,
  buildPythonPackage,
  certifi,
  chardet,
  charset-normalizer,
  fetchPypi,
  idna,
  pysocks,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  pythonOlder,
  urllib3,
  hatchling,
  urllib3-future,
  wassima,
  kiss-headers,
  cryptography,
  pytest-asyncio,
  pytest-httpbin,
  trustme,

}:

buildPythonPackage rec {
  pname = "niquests";
  version = "3.7.2";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  __darwinAllowLocalNetworking = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xcqe1ybgDbOSsgrGSjeihB7HH0+zUplmIqbLaTymNak=";
  };

  dependencies = [
    hatchling
    charset-normalizer
    idna
    wassima
    kiss-headers
    cryptography
    urllib3-future
  ];

  disabledTests =
    [
      # uses external network connection
      "test_ensure_ipv6"

      # fails as it raises different error than expected (error is more granular than expected)
      # ie, port cant be cast to int, vs the expected, more general, InvalidURL
      "test_redirecting_to_bad_url"

      "test_connect_timeout"
      "test_total_timeout_connect"
    ];

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytest-httpbin
    pytest-xdist
    trustme
    pytestCheckHook
  ];

  pythonImportsCheck = [ "niquests" ];

  meta = with lib; {
    description = "Niquests is a simple, yet elegant, HTTP library";
    homepage = "https://niquests.readthedocs.io/en/latest/";
    changelog = "https://github.com/jawah/niquests/blob/v${version}/HISTORY.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
