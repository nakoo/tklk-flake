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
  version = "2.10.904";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jawah";
    repo = "urllib3.future";
    rev = version;
    hash = "sha256-VkYZdmUITiK7rKbtUtTr0Nl7G86vKhgAOMfw9VXWxKI=";
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

  pythonImportsCheck = [ "urllib3_future" ];

  disabledTests = [
    "test_doh_rfc8484"
    "test_task_safe_resolver" # relies on external dns server
  ];
  disabledTestPaths = [
    "test/contrib/test_resolver.py"
    "test/contrib/asynchronous/test_socks.py"
    "test/test_poolmanager.py"
    "test/with_dummyserver/test_socketlevel.py"
    "test/with_dummyserver/test_connectionpool.py"
    "test/with_dummyserver/test_proxy_poolmanager.py"
    "test/with_dummyserver/asynchronous/test_happy_eyeballs.py"
    "test/with_dummyserver/asynchronous/test_connectionpool.py"
    "test/with_dummyserver/asynchronous/test_poolmanager.py"
  ];

  meta = with lib; {
    description = "Powerful, user-friendly HTTP client for Python";
    homepage = "https://urllib3future.readthedocs.io/en/latest/";
    changelog = "https://github.com/jawah/urllib3.future/blob/${version}/CHANGES.rst";
    license = licenses.mit;
    maintainers = [ ];
  };
}
