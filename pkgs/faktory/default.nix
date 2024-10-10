{
  lib,
  buildGoModule,
  fetchFromGitHub,
  redis,
}:

buildGoModule rec {
  pname = "faktory";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "contribsys";
    repo = "faktory";
    rev = "v${version}";
    hash = "sha256-nRQJh276JvNeR1WovVzRmkbqEcydAjUDnFuQp5UFC7E=";
  };

  vendorHash = "sha256-rXaD2ZqH1Fo5R5BDecI+1rpMghCVeps5NFIKlHFSvAc=";

  postPatch = ''
    # the substitute looks strang for the error, but that is because it can't have a direct nil return, it needs to be a nil error
    # it also hardcodes the path to the redis-server binary to the nix store path
    substituteInPlace storage/redis.go \
      --replace-fail 'binary, err := exec.LookPath("redis-server")' \
                     'binary, err := "${redis}/bin/redis-server", (error)(nil)'

    # replace writing to /tmp, with the tmp directory that should be used instead
    # this is because /tmp is read-only for sandboxing
    substituteInPlace storage/redis_test.go \
      --replace-fail 'dir := fmt.Sprintf("/tmp/faktory-test-%s", name)' \
                     'dir, _ := os.MkdirTemp("", "faktory-test")'
    substituteInPlace manager/manager_test.go \
      --replace-fail 'dir := fmt.Sprintf("/tmp/faktory-test-%s", name)' \
                     'dir, _ := os.MkdirTemp("", "faktory-test")'
  '';

  nativeBuildInputs = [
    redis
  ];

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Language-agnostic persistent background job server";
    homepage = "https://github.com/contribsyss/faktory";
    changelog = "https://github.com/contribsys/faktory/blob/${src.rev}/Changes.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "faktory";
  };
}
