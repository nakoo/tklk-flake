{
  lib,
  stdenv,
  fetchFromGitHub,
  mkYarnPackage,
  makeWrapper,
  nodejs,
}:

mkYarnPackage rec {
  pname = "aidev";
  version = "unstable-2024-10-14";

  src = fetchFromGitHub {
    owner = "efritz";
    repo = "aidev";
    rev = "c1b3c0d3ea803d87de99bb136908e2d9163775c0";
    hash = "sha256-Jt3LDlF2SdwfBjX/hz7ymwpCBZVA4d6Gsm48/4m+jXI=";
  };

  packageJSON = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/efritz/aidev/c1b3c0d3ea803d87de99bb136908e2d9163775c0/package.json";
    sha256 = "sha256-Hm9eEyU1B+CmGC+5VnLEnn0pAJg2HcOUDEGFBc2XrMA=";
  };

  postPatch = ''
    substituteInPlace src/providers/keys.ts \
      --replace "path.join(homedir(), 'dev', 'efritz', 'aidev')" \
                "path.join(process.env.XDG_CONFIG_HOME || path.join(homedir(), '.config'), 'aidev')"
  '';

  nativeBuildInputs = [ makeWrapper ];

  buildPhase = ''
    yarn build
  '';

  postInstall = ''
    makeWrapper ${nodejs}/bin/node $out/bin/aidev \
      --add-flags $out/bin/ai \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
    # bin/ai is a symlink to $out/libexec/ai/deps/ai/dist/cli.mjs
  '';

  meta = {
    description = "Personalized LLM assistant in VSCode + terminal";
    homepage = "https://github.com/efritz/aidev";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "aidev";
    platforms = lib.platforms.all;
  };
}
