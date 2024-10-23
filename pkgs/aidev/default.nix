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
  version = "unstable-2024-10-22";

  src = fetchFromGitHub {
    owner = "efritz";
    repo = "aidev";
    rev = "7ae03d31153b400503e290030b725fd72ccf8095";
    hash = "sha256-GeU38CdGI7vAqgrcJAHr0WNyCzjwak00dNTsY6voPhY=";
  };

  packageJSON = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/efritz/aidev/7ae03d31153b400503e290030b725fd72ccf8095/package.json";
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
