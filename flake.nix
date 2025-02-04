{
  description = ''
    techknow's bargin basement collection of packages

    packages that I need for one off reasons, or that I don't
    have the time to maintain properly for nixpkgs.
  '';

  nixConfig = {
    extra-substituters = [ "http://cache.tklk.dev/tklk" ];
    extra-trusted-public-keys = [ "tklk:rZcfXQZR52zK/CPWEhbn/kW7j102wOLCkWqgZIhWSYI=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # import nixpkgs-unstable for use on darwin
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-darwin,
      flake-utils,
      attic,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # some of the python packages need to be included as an overlay to be imported correctly
        overlays = [
          (self: super: {
            urllib3-future = super.python3Packages.callPackage ./pkgs/urllib3-future { };
            wassima = super.python3Packages.callPackage ./pkgs/wassima { };
            jh2 = super.python3Packages.callPackage ./pkgs/jh2 { };
            qh3 = super.python3Packages.callPackage ./pkgs/qh3 { };
            niquests = super.python3Packages.callPackage ./pkgs/niquests { };
          })
          # overlay nixpkgs' httpie
          (self: super: {
            httpie = super.httpie.overrideAttrs (oldAttrs: rec {
              version = "4.0.0-dev";
              postPatch =
                oldAttrs.postPatch or ""
                + ''
                  # disable remote httpbin tests (network access is required)
                  substituteInPlace tests/conftest.py --replace 'if _remote_httpbin_available:' 'if False:'
                '';
              propagatedBuildInputs = oldAttrs.propagatedBuildInputs or [ ] ++ [ super.niquests ];
              checkInputs = oldAttrs.checkInputs or [ ] ++ [ super.coreutils ]; # tests need access to various coreutils bins
              disabledTests = oldAttrs.disabledTests or [ ] ++ [
                "test_config_dir_is_created"
                "test_ensure_resolver_used"
                "test_incomplete_response"
                "test_main_entry_point"
                "test_daemon_runner"
                "test_secure_cookies_on_localhost"
                # httpbin doesn't like chunked (maybe?)
                "test_verbose_chunked"
                "test_chunked_json"
                "test_chunked_form"
                "test_chunked_stdin"
                "test_chunked_stdin_multiple_chunks"
                "test_request_body_from_file_by_path_chunked"
                "test_chunked_raw"
                "test_multipart_chunked"
              ];
              src = super.fetchFromGitHub {
                owner = "Ousret";
                repo = "httpie";
                rev = "e375c259e8f3a9d408b1877b628d94bf7e20350f";
                hash = "sha256-/fsxwaIHNF/2KJgtFDAKROFNYZ3A8EHC1VQufq7hoGE=";
              };
            });
          })
          (self: super: {
            # awaiting PR #349071
            nomad-pack = super.nomad-pack.overrideAttrs (oldAttrs: rec {
              version = "0.2.0";
              src = super.fetchFromGitHub {
                owner = "hashicorp";
                repo = "nomad-pack";
                rev = "v${version}";
                hash = "sha256-dw6sueC1qibJYc6sbZX8HJlEf9R6O8dlE1aobw70UHw=";
              };
              vendorHash = "sha256-BKYJ9FZXKpFwK3+mrZAXRkfitSY9jeOLLeC0BOsKc/A=";
            });
          })
          (self: super: {
            # change default to 1.9
            nomad = allPackages.nomad_1_9;
          })
        ];
        # Determine if the system is Darwin
        pkgs =
          if builtins.match ".*-darwin" system != null then
            import nixpkgs-darwin {
              inherit system;
              config.allowUnfree = true;
              overlays = overlays;
            }
          else
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = overlays;
            };
        pythonPackages = pkgs.python3Packages;
        # Script to push packages to Attic
        pushPackagesScript = pkgs.writeShellApplication {
          name = "push-packages";
          runtimeInputs = with pkgs; [
            jq
            nix
            attic
            coreutils
          ];
          text = ''
            #!/usr/bin/env bash
            set -euo pipefail

            # Push flake inputs
            nix flake archive --json | jq -r '.path,(.inputs|to_entries[].value.path)' | xargs -I {} attic push tklk {}

            # Get packages for the current system
            CURRENT_SYSTEM="${system}"
            PACKAGES=$(nix flake show --json . 2>/dev/null | jq -r --arg cur_sys "$CURRENT_SYSTEM" '.packages[$cur_sys]|(try keys[] catch "")')

            if [ -n "$PACKAGES" ]; then
              echo "$PACKAGES" | while read -r pkg; do
                echo "Checking package: $pkg"

                # Get the store paths for the package (there might be multiple outputs)
                readarray -t STORE_PATHS < <(nix build -L --accept-flake-config --print-out-paths .#"$pkg")

                for STORE_PATH in "''${STORE_PATHS[@]}"; do
                  # Remove any trailing newline
                  STORE_PATH=$(echo -n "$STORE_PATH" | tr -d '\n')
                  echo "Pushing $pkg to cache..."
                  nix-store -qR "$STORE_PATH" | xargs -I {} attic push tklk {}
                done
              done
            fi
          '';
        };
        allPackages = {
          # pre-build attic binaries
          attic = attic.packages.${system}.attic;
          attic-client = attic.packages.${system}.attic-client;
          attic-server = attic.packages.${system}.attic-server;

          # python packages
          jh2 = pythonPackages.callPackage ./pkgs/jh2 { };
          niquests = pythonPackages.callPackage ./pkgs/niquests { };
          qh3 = pythonPackages.callPackage ./pkgs/qh3 { };
          urllib3-future = pythonPackages.callPackage ./pkgs/urllib3-future { };
          wassima = pythonPackages.callPackage ./pkgs/wassima { };

          # httpie with niquests support (aka http2&3 support)
          httpie = pkgs.httpie;

          git-lfs = pkgs.git-lfs;
          yarn2nix = pkgs.yarn2nix;
          nix-prefetch-git = pkgs.nix-prefetch-git;

          # cloud native tools
          cilium-cni = pkgs.callPackage ./pkgs/cilium-cni { };
          consul-cni = pkgs.callPackage ./pkgs/consul-cni { };
          grpcmd = pkgs.callPackage ./pkgs/grpcmd { };
          tc-redirect-tap = pkgs.callPackage ./pkgs/tc-redirect-tap { };

          # misc
          aidev = pkgs.callPackage ./pkgs/aidev { };
          comply = pkgs.callPackage ./pkgs/comply { };
          cryptfs = pkgs.callPackage ./pkgs/cryptfs-cli { };
          faktory = pkgs.callPackage ./pkgs/faktory { };
          goat = pkgs.callPackage ./pkgs/goat { };
          priscope = pkgs.callPackage ./pkgs/priscope { };

          # non-free packages to cache in personal binary store
          terraform = pkgs.terraform;
          vault = pkgs.vault;
          vault-bin = pkgs.vault-bin;
          nomad_1_8 = pkgs.nomad_1_8;
          nomad = pkgs.nomad;
          nomad_1_9 = pkgs.callPackage ./pkgs/nomad_1_9 { };
          consul = pkgs.consul;
          boundary = pkgs.boundary;
          packer = pkgs.packer;
          nomad-pack = pkgs.nomad-pack; # uses mozilla license (but grouping with other hashicorp tools)

          zerotierone = pkgs.zerotierone;

          sublime4 = pkgs.callPackage ./pkgs/sublimetext4 { };
          sublime4-dev = pkgs.callPackage ./pkgs/sublimetext4 { dev = true; };
        };
        # Helper function to check if a package is supported on the current system
        isSupported = pkg: (pkg.meta.platforms or [ ]) == [ ] || builtins.elem system pkg.meta.platforms;
        # Filter packages based on system support
        supportedPackages = nixpkgs.lib.filterAttrs (name: pkg: pkg != null && isSupported pkg) allPackages;
      in
      {
        packages = supportedPackages;
        apps = {
          push-packages = {
            type = "app";
            program = "${pushPackagesScript}/bin/push-packages";
          };
        };
      }
    );
}
