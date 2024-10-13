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
  version = "3.9.1";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  __darwinAllowLocalNetworking = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TkPX58JHNA/fP2HgTLxoqKpu68oAx2zaFoMlq4yqTqE=";
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

  disabledTests = [
    # uses external network connection
    "test_ensure_ipv6"

    # fails as it raises different error than expected (error is more granular than expected)
    # ie, port cant be cast to int, vs the expected, more general, InvalidURL
    "test_redirecting_to_bad_url"

    "test_connect_timeout"
    "test_total_timeout_connect"

    # fails due to temporary issue with remote config
    "test_ensure_http3_default"

    # remote network connection to pie.dev
    "test_awaitable_get"
    "test_ensure_ipv4"
    "test_awaitable_redirect_chain"
    "test_ensure_http2"
    "test_awaitable_redirect_chain_stream"
    "test_not_owned_resolver"
    "test_async_session_cookie_dummylock"
    "test_owned_resolver_must_close"
    "test_concurrent_task_get"
    "test_owned_resolver_must_recycle"
    "test_with_async_auth"
    "test_with_stream_json"
    "test_with_stream_text"
    "test_with_stream_iter_decode"
    "test_with_stream_iter_raw"

    "test_one_at_a_time"
    "test_early_close_no_error"
    "test_lazy_access_sync_mode"
    "test_get_stream_with_multiplexed"
    "test_concurrent_request_in_sync"
    "test_concurrent_task_get_with_stream"
    "test_redirect_with_multiplexed"
    "test_redirect_with_multiplexed_direct_access"
    "test_awaitable_get"
    "test_awaitable_redirect_chain"
    "test_awaitable_redirect_with_lazy"
    "test_awaitable_get_direct_access_lazy"
    "test_awaitable_redirect_direct_access_with_lazy"
    "test_awaitable_stream_redirect_direct_access_with_lazy"
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
