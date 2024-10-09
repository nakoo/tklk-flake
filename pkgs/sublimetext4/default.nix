{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  unzip,
  dev ? false,
  ...
}:
let
  sublime4-darwin-common =
    {
      version,
      dev ? false,
      hash,
      ...
    }:
    stdenv.mkDerivation (finalAttrs: rec {
      pname = "sublimetext4${lib.optionalString dev "-dev"}";
      inherit version;
      src = fetchurl {
        url = "https://download.sublimetext.com/sublime_text_build_${version}_mac.zip";
        inherit hash;
      };
      nativeBuildInputs = [
        makeWrapper
        unzip
      ];
      installPhase = ''
        runHook preInstall
        mkdir -p $out/{Applications/Sublime\ Text.app,bin}
        cp -R . $out/Applications/Sublime\ Text.app
        makeWrapper $out/Applications/Sublime\ Text.app/Contents/MacOS/sublime_text $out/bin/${pname}
        runHook postInstall
      '';
      meta = {
        description = "Sophisticated text editor for code, markup and prose";
        homepage = "https://www.sublimetext.com/";
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        license = lib.licenses.unfree;
        platforms = [
          "x86_64-darwin"
          "aarch64-darwin"
        ];
      };
    });
  # find latest versions at: "https://download.sublimetext.com/latest/${if dev then "dev" else "stable"}";
  sublime4 = sublime4-darwin-common {
    dev = false;
    version = "4180";
    hash = "sha256-StlxuTKEnsXkB0DlBS7lEIsO0whny+aAJNLkNqGeYNA=";
  };
  sublime4-dev = sublime4-darwin-common {
    dev = true;
    version = "4183";
    hash = "sha256-5BiTuSgi9LQqIo2dW13QqALB6s/4bO17MnFQpztFTGc=";
  };
in
if dev then sublime4-dev else sublime4
