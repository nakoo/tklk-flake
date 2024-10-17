{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "comply";
  version = "1.6.0+nightly";

  src = fetchFromGitHub {
    owner = "strongdm";
    repo = "comply";
    rev = "aab484948d71417e35a079c0395bcf42e16a8dd9";
    hash = "sha256-sDtB567wVQVoPOtellFWgD2s5BA9ptskMyu9X03gqME=";
  };

  prePatch = ''
    rm -rf vendor
  '';

  vendorHash = "sha256-M8bPhKl+GxnUMfc20SteTKPONTyfRBYWPeeWsJzARt0=";

  subPackages = [ "." ];

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Compliance automation framework, focused on SOC2";
    homepage = "https://github.com/strongdm/comply";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "comply";
  };
}
