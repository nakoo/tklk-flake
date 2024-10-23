{
  lib,
  python3,
  fetchFromGitHub,
  makeWrapper,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "priscope";
  version = "unstable-2024-10-20";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "marklechner";
    repo = "priscope";
    rev = "cd7995ecfcb20f016b6e4ad37d3c2ff7f318428b";
    hash = "sha256-LZUa0XV95RFtOZix641K7mOOcMEoyiwUd/pakV6K25w=";
  };

  postPatch = ''
    cat <<EOF >> pyproject.toml

[build-system]
requires = ["setuptools>=45", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "priscope"
version = "0.0.1-dev"
description = "A security tool for reviewing merged code changes in open source repositories"

[tool.setuptools]
py-modules = ["priscope", "logo"]
EOF
   # Replace the load_config function in priscope.py
    sed -i '/def load_config()/,/^$/c\
def load_config():\
    default_config = {\
        "max_prs_per_page": 30,\
        "ollama_url": "http://localhost:11434",\
        "api_endpoint": "/api/generate",\
        "model_name": "mistral-small-128k"\
    }\
    try:\
        with open("config.json", "r") as config_file:\
            user_config = json.load(config_file)\
            # Merge user_config with default_config, user_config settings take precedence\
            config = {**default_config, **user_config}\
    except FileNotFoundError:\
        config = default_config\
    return config\
' priscope.py
  '';

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  dependencies = with python3.pkgs; [
    bandit
    black
    certifi
    cfgv
    charset-normalizer
    click
    distlib
    filelock
    flake8
    identify
    idna
    isort
    markdown-it-py
    mccabe
    mdurl
    mypy
    mypy-extensions
    nodeenv
    packaging
    pathspec
    pbr
    platformdirs
    pre-commit-hooks
    pycodestyle
    pyflakes
    pygments
    python-dateutil
    pyyaml
    requests
    rich
    six
    stevedore
    termcolor
    textwrap3
    types-requests
    typing-extensions
    urllib3
    virtualenv
  ];

  postInstall = ''
    # Create a wrapper script
    mkdir -p $out/bin
    cat > $out/bin/priscope <<EOF
    #!${python3}/bin/python3
    import sys
    import priscope

    if __name__ == '__main__':
        sys.exit(priscope.main())
    EOF
    chmod +x $out/bin/priscope
  '';

  # no tests exist
  pytestCheckPhase = "echo 'Skipping pytest check phase'";

  meta = {
    description = "A security tool designed to help review merged code changes to open source maintained repositories via LLM assisted review to safeguard against supply chain attacks";
    homepage = "https://github.com/marklechner/priscope";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "priscope";
  };
}
