{
  lib,
  buildGo123Module,
  fetchFromGitHub,
}:

buildGo123Module rec {
  pname = "cryptfs";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "moov-io";
    repo = "cryptfs";
    rev = "v${version}";
    hash = "sha256-Fd4Lh0nZtDjSk4HgavZSnw9EyXsx6O2E+hGTCSP2FpM=";
  };

  subPackages = [ "cmd/cryptfs" ];

  vendorHash = "sha256-A/q0mMU/YehmZchMfiC+eZbzrn1CNGpPYLYDV108gpk=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Implementation of io/fs.FS that transparently encrypts and decrypts files";
    homepage = "https://github.com/moov-io/cryptfs";
    changelog = "https://github.com/moov-io/cryptfs/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "cryptfs";
  };
}
