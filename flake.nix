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
      flake-utils,
      attic,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;

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
                postPatch = oldAttrs.postPatch or "" + ''
                  # disable remote httpbin tests (network access is required)
                  substituteInPlace tests/conftest.py --replace 'if _remote_httpbin_available:' 'if False:'
                '';
                propagatedBuildInputs = oldAttrs.propagatedBuildInputs or [ ] ++ [ super.niquests ];
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
                  rev = "2e3617ecdbc8cabab404fe3133ae671df8579b04";
                  hash = "sha256-4TiItfVVJr6uJO8GtjN52NysWzwSJ2+l/Uh1mFE9cx0=";
                };
              });
            })
            (self: super: {
              # remove overlay when nomad_1_8 is made as default
              nomad = super.nomad.overrideAttrs (oldAttrs: rec {
                meta = oldAttrs.meta // {
                  platforms = [ nixpkgs.lib.platforms.linux ];
                };
              });
            })
          ];
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

            CACHE_URL="http://cache.tklk.dev/tklk"

            # Push flake inputs
            nix flake archive --json | jq -r '.path,(.inputs|to_entries[].value.path)' | xargs -I {} attic push tklk {}

            # Get packages for the current system
            CURRENT_SYSTEM="${system}"
            PACKAGES=$(nix flake show --json . 2>/dev/null | jq -r --arg cur_sys "$CURRENT_SYSTEM" '.packages[$cur_sys]|(try keys[] catch "")')

            check_in_cache() {
              local output_path="$1"
              nix-store --query --store "$CACHE_URL" "$output_path" > /dev/null 2>&1
              return $?
            }

            if [ -n "$PACKAGES" ]; then
              echo "$PACKAGES" | while read -r pkg; do
                echo "Checking package: $pkg"

                # Get the derivation path using nix eval
                DRV_PATH=$(nix eval --raw .#"$pkg".drvPath 2>/dev/null)

                # Get the output paths without building
                OUT_PATHS=$(nix-store --query --outputs "$DRV_PATH")

                NEED_BUILD=false
                for OUT_PATH in $OUT_PATHS; do
                  if ! check_in_cache "$OUT_PATH"; then
                    NEED_BUILD=true
                    break
                  fi
                done

                if [ "$NEED_BUILD" = true ]; then
                  echo "Building $pkg and pushing to cache..."
                  nix build --no-link --accept-flake-config .#"$pkg" 2>/dev/null
                  for OUT_PATH in $OUT_PATHS; do
                    nix-store -qR "$OUT_PATH" | xargs -I {} attic push tklk {}
                  done
                else
                  echo "Package $pkg already exists in cache, skipping..."
                fi
              done
            fi
          '';
        };
        allPackages = {
          # python packages
          jh2 = pythonPackages.callPackage ./pkgs/jh2 { };
          niquests = pythonPackages.callPackage ./pkgs/niquests { };
          qh3 = pythonPackages.callPackage ./pkgs/qh3 { };
          urllib3-future = pythonPackages.callPackage ./pkgs/urllib3-future { };
          wassima = pythonPackages.callPackage ./pkgs/wassima { };

          # export httpie with niquests support (aka http2&3 support)
          httpie = pkgs.httpie;

          cilium-cni = pkgs.callPackage ./pkgs/cilium-cni { };
          grpcmd = pkgs.callPackage ./pkgs/grpcmd { };
          kine = pkgs.callPackage ./pkgs/kine { };
          bio-rd = pkgs.callPackage ./pkgs/bio-rd { };

          # pending merge of PR: https://github.com/NixOS/nixpkgs/pull/330775
          nomad-driver-containerd = pkgs.callPackage ./pkgs/nomad-driver-containerd { };

          # non-free packages to cache in personal binary store
          terraform = pkgs.terraform;
          vault = pkgs.vault;
          nomad = pkgs.nomad;
          nomad_1_8 = pkgs.nomad_1_8;
          consul = pkgs.consul;
          boundary = pkgs.boundary;
          packer = pkgs.packer;

          zerotierone = pkgs.zerotierone;

          sublime4 = pkgs.callPackage ./pkgs/sublimetext4 { };
          sublime4-dev = pkgs.callPackage ./pkgs/sublimetext4 { dev = true; };

          # pre-build attic binaries
          attic = attic.packages.${system}.attic;
          attic-client = attic.packages.${system}.attic-client;
          attic-server = attic.packages.${system}.attic-server;
        };
        # Helper function to check if a package is supported on the current system
        isSupported = pkg: (pkg.meta.platforms or [ ]) == [ ] || builtins.elem system pkg.meta.platforms;
        # Filter packages based on system support
        supportedPackages = nixpkgs.lib.filterAttrs (name: pkg:
          pkg != null && isSupported pkg
        ) allPackages;
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
