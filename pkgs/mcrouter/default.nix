{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  autoconf,
  automake,
  pkg-config,
  cmake,
  ninja,
  fbthrift,
  python3,
  python3Packages,
  glog,
  gflags,
  libiberty,
  lz4,
  xz,
  zstd,
  jemalloc,
  boost,
  libevent,
  openssl,
  zlib,
  double-conversion,
  folly,
  libsodium,
  libunwind,
  fizz,
  libtool,
  gtest,
  ragel,
  fmt,
  fast-float,
  bzip2,
  mvfst,
  fetchpatch,
  libaio,
  liburing,
  libdwarf,
  snappy,
  wangle,
}:
let
  folly' = folly.overrideAttrs (oldAttrs: rec {
    version = "2024.10.07.00";
    src = fetchFromGitHub {
      owner = "facebook";
      repo = "folly";
      rev = "v${version}";
      hash = "sha256-+55ahY+JYgW7f8f/eoMwTvxmuDOZ0NSyyiVeCZRugsg=";
    };
    passthru = {
      fmt = fmt;
    };
    # remove fmt_8 from buildInputs array
    buildInputs = [
      boost
      double-conversion
      glog
      gflags
      libevent
      libiberty
      openssl
      lz4
      xz
      zlib
      libunwind
      fmt
      zstd
      fast-float
      libsodium
      libaio
      liburing
      libdwarf
      snappy
      bzip2
    ] ++ lib.optional stdenv.hostPlatform.isLinux jemalloc;
  });
  fizz' = fizz.overrideAttrs (oldAttrs: rec {
    version = "2024.10.07.00";
    src = fetchFromGitHub {
      owner = "facebookincubator";
      repo = "fizz";
      rev = "v${version}";
      hash = "sha256-flvnOSv0cDC8DXSrByoHnJWiKQocII0Kc3hsSneBeVU=";
    };
    buildInputs = [
      fmt
      boost
      double-conversion
      folly'
      glog
      gflags
      libevent
      libiberty
      libsodium
      openssl
      zlib
      zstd
    ];
  });
  mvfst' = mvfst.overrideAttrs (oldAttrs: rec {
    version = "2024.10.07.00";
    src = fetchFromGitHub {
      owner = "facebookincubator";
      repo = "mvfst";
      rev = "v${version}";
      hash = "sha256-8IW/ZUsbfoOppRZ7jhMFnrtolyh2J7QNkc8Zr1U77ks=";
    };
    buildInputs = [
      fizz'
      folly'
      boost
      fmt
      gflags
      glog
      libsodium
      zlib
    ];
  });
  wangle' = wangle.overrideAttrs (oldAttrs: rec {
    version = "2024.10.07.00";
    src = fetchFromGitHub {
      owner = "facebook";
      repo = "wangle";
      rev = "v${version}";
      hash = "sha256-5xKT5ZHFCWv4N+f07V4MneYCOQCWL6K+58hRq2yZWDk=";
    };

    # disable tests
    doCheck = false;

    buildInputs = [
      fmt
      libsodium
      zlib
      boost
      libunwind
      double-conversion
      fizz'
      folly'
      glog
      gflags
      libevent
      openssl
    ];
  });
  fbthrift' = fbthrift.overrideAttrs (oldAttrs: rec {
    version = "2024.10.07.00";
    src = fetchFromGitHub {
      owner = "facebook";
      repo = "fbthrift";
      rev = "v${version}";
      hash = "sha256-x71Coo/Q57xZAd4HBdEinx94phDaVzK8hyLPspRc3Z4=";
    };
    buildInputs = [
      boost
      double-conversion
      fizz'
      folly'
      python3
      libunwind
      fmt
      glog
      gflags
      libevent
      libiberty
      mvfst'
      openssl
      wangle'
      zlib
      zstd
      libsodium
    ];

  });
in
stdenv.mkDerivation rec {
  pname = "mcrouter";
  version = "2024.10.07.00";
  src = fetchFromGitHub {
    owner = "facebook";
    repo = "mcrouter";
    rev = "v${version}";
    hash = "sha256-2I16LoGSuShaZrHtM2G5bzv4rFpvShXteeJJj+2MwWY=";
  };
  sourceRoot = "${src.name}/mcrouter";

  postPatch = ''
    find . -name Makefile.am -exec sed -i 's#@FBTHRIFT@#@FBTHRIFT@ -I ${fbthrift}/include -I ${fbthrift}/include/thrift/lib -I ${fbthrift}/lib#g' {} +
  '';

  env = {
    FBTHRIFT_BIN = "${fbthrift}/bin";
    BOOST_LDFLAGS = "-L${boost.out}/lib";
    FBTHRIFT_TEMPLATES = "${fbthrift}/include/thrift/templates";
    THRIFT_INCLUDE_DIR = "${fbthrift}/include";
    THRIFT_LIB_DIR = "${fbthrift}/lib";

  };

  configureFlags = [
    "--disable-tests"
    "--with-boost=${boost.dev}"
    "--with-boost-libdir=${boost.out}/lib"
    "--with-fmt=${fmt}"
    "--with-folly=${folly'}"
    "--with-thrift=${fbthrift}"
  ];

  CPPFLAGS = [
    "-I${fbthrift}/include"
    "-I${folly'}/include"
    "-I${glog}/include"
    "-I${double-conversion}/include"
    "-I${fmt}/include"
  ];

  LDFLAGS = [
    "-L${boost.out}/lib"
    "-L${folly'}/lib"
    "-L${fbthrift}/lib"
    "-L${fmt}/lib"
  ];

  buildInputs = [
    boost
    fbthrift'
    glog
    boost
    libevent
    openssl
    zlib
    double-conversion
    folly'
    libsodium
    python3
    fizz
    gtest
    fmt
    mvfst
  ];

  nativeBuildInputs = [
    autoreconfHook
    autoconf
    automake
    pkg-config
    python3Packages.distutils
    ragel
    libtool
  ];
  meta = {
    platforms = lib.platforms.linux;
  };
}
