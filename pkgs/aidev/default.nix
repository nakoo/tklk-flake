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
  version = "unstable-2024-10-09";

  src = fetchFromGitHub {
    owner = "efritz";
    repo = "aidev";
    rev = "8d71937e0ef4db86e75f4c04503c001aea5d1b63";
    hash = "sha256-j0mFVCF6Jh1KGf4xh2dA7qraqod5RMcgK1eb4v56/pE=";
  };

  packageJSON = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/efritz/aidev/8d71937e0ef4db86e75f4c04503c001aea5d1b63/package.json";
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
