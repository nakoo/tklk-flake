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
            nomad_1_8 = super.nomad.overrideAttrs (oldAttrs: rec {
              version = "1.8.4";
              src = super.fetchFromGitHub {
                owner = "hashicorp";
                repo = "nomad";
                rev = "v${version}";
                hash = "sha256-BzLvALD65VqWNB9gx4BgI/mYWLNeHzp6WSXD/1Xf0Wk=";
              };
              vendorHash = "sha256-0mnhZeiCLAWvwAoNBJtwss85vhYCrf/5I1AhyXTFnWk=";
            });
            # temporary, until PR #344262 is merged
            nomad-pack = super.nomad-pack.overrideAttrs (oldAttrs: rec {
              version = "nightly-2024-09-23";
              src = super.fetchFromGitHub {
                owner = "hashicorp";
                repo = "nomad-pack";
                rev = "3c0178a561b360906c591718edb25ae25ae9d964"; # nightly tag as of 2024-09-23
                hash = "sha256-8erw+8ZTpf8Dc9m6t5NeRgwOETkjXN/wVhoZ4g0uWhg=";
              };
              vendorHash = "sha256-Rt0T6cCMzO4YBFF6/9xeCZcsqziDmxPMNirHLqepwek=";
            });
            # temporary, until PR #345989 is merged
            terraform = super.terraform.overrideAttrs (oldAttrs: rec {
              version = "1.9.7";
              src = super.fetchFromGitHub {
                owner = "hashicorp";
                repo = "terraform";
                rev = "v${version}";
                hash = "sha256-L0F0u96et18IlqAUsc0HK+cLeav2OqN4kxs58hPNMIM=";
              };
              vendorHash = "sha256-tH9KQF4oHcQh34ikB9Bx6fij/iLZN+waxv5ZilqGGlU=";
            });
            # temporary, until PR hydra builds the merged PR
            go_1_22 = super.go_1_22.overrideAttrs (oldAttrs: rec {
              version = "1.22.8";
              src = super.fetchurl {
                url = "https://go.dev/dl/go${version}.src.tar.gz";
                hash = "sha256-3xLCPr8Z3qD0v0aiLL7aSj7Kb0dPMYOQzndJdCeEQLg=";
              };
            });
            go_1_23 = super.go_1_23.overrideAttrs (oldAttrs: rec {
              version = "1.23.2";
              src = super.fetchurl {
                url = "https://go.dev/dl/go${version}.src.tar.gz";
                hash = "sha256-NpMBYqk99BfZC9IsbhTa/0cFuqwrAkGO3aZxzfqc0H8=";
              };
            });
            # temporary, until PR #344555 is merged
            vault = super.vault.overrideAttrs (oldAttrs: rec {
              version = "1.17.6";
              src = super.fetchFromGitHub {
                owner = "hashicorp";
                repo = "vault";
                rev = "v${version}";
                hash = "sha256-sd4gNNJ/DVpl7ReymykNemWz4NNisofMIH6lLNl+iVw=";
              };
              vendorHash = "sha256-V7aMf03U2DTNg1murp4LBfuOioA+7iG6jX9o05rhM2U=";
            });
            vault-bin = super.vault-bin.overrideAttrs (oldAttrs: rec {
              version = "1.17.6";
              src =
                let
                  inherit (super.stdenv.hostPlatform) system;
                  selectSystem = attrs: attrs.${system} or (throw "Unsupported system: ${system}");
                  suffix = selectSystem {
                    x86_64-linux = "linux_amd64";
                    aarch64-linux = "linux_arm64";
                    i686-linux = "linux_386";
                    x86_64-darwin = "darwin_amd64";
                    aarch64-darwin = "darwin_arm64";
                  };
                  hash = selectSystem {
                    x86_64-linux = "sha256-K9yNZ4M8u8FfisWi6Y6TsBJy6FQytr3htNCsKh2MlyA=";
                    aarch64-linux = "sha256-KLHkxUGvekHT/bPtoIlmylCubTWH+I7Q0wJM0UG0Hp8=";
                    i686-linux = "sha256-jBS/nGKP27weFw4u6Q10athYwCqWLzpb7ph39v+QAN8=";
                    x86_64-darwin = "sha256-5KfWqtJldk66dO5ImYKivDau4JzacUIXBfAzWkkPfoE=";
                    aarch64-darwin = "sha256-wjmNY1lunJDjpkWDXl0upAeNBqBx8momlY4a3j+hMd0=";
                  };
                in
                super.fetchzip {
                  url = "https://releases.hashicorp.com/vault/${version}/vault_${version}_${suffix}.zip";
                  stripRoot = false;
                  inherit hash;
                };
            });
            # temporary, until PR #331913 is merged
            boundary = super.boundary.overrideAttrs (oldAttrs: rec {
              version = "0.17.1";
              src =
                let
                  inherit (super.stdenv.hostPlatform) system;
                  selectSystem = attrs: attrs.${system} or (throw "Unsupported system: ${system}");
                  suffix = selectSystem {
                    x86_64-linux = "linux_amd64";
                    aarch64-linux = "linux_arm64";
                    x86_64-darwin = "darwin_amd64";
                    aarch64-darwin = "darwin_arm64";
                  };
                  hash = selectSystem {
                    x86_64-linux = "sha256-U7ZCmpmcZpgLkf2jwc35Q9jezxUzaKp85WX2Tqs5IFI=";
                    aarch64-linux = "sha256-gYbeC+f/EXfhzUtwojjvyEATri1XpHpu+JPQtj4oRb4=";
                    x86_64-darwin = "sha256-N6Uy5JiU9mW1/muHYF6Rf1KLX1iXYt/5ct1IHeFUgds=";
                    aarch64-darwin = "sha256-Oxfzy/9ggcJXS+tXiYmJXSiqbMKw4vv9RMquUuOlJ08=";
                  };
                in
                super.fetchzip {
                  url = "https://releases.hashicorp.com/boundary/${version}/boundary_${version}_${suffix}.zip";
                  inherit hash;
                  stripRoot = false;
                };
            });
          })
          (self: super: {
            # change default to 1.8
            nomad = super.nomad_1_8;
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
        updatePackagesScript = pkgs.writeShellApplication {
          name = "update-packages";
          runtimeInputs = with pkgs; [
            jq
            nix
            coreutils
          ];
          text = ''
            #!/usr/bin/env bash
            set -euo pipefail

            # get packages by folder name under pkgs directory
            PACKAGES=$(find ./pkgs -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
            PACKAGES+=" " # add packages here that are only define in flake.nix (such as nomad_1_8 bump)
            
            if [ -n "$PACKAGES" ]; then
              echo "$PACKAGES" | while read -r pkg; do
                echo "Checking package: $pkg"
                if nix eval ".#$pkg" --json >/dev/null 2>&1; then
                  # FIXME: pin to a specific version of nix-update
                  nix run github:Mic92/nix-update -- -F "$pkg"
                fi
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

          go_1_22 = pkgs.go_1_22;
          go_1_23 = pkgs.go_1_23;

          # cloud native tools
          cilium-cni = pkgs.callPackage ./pkgs/cilium-cni { };
          consul-cni = pkgs.callPackage ./pkgs/consul-cni { };
          grpcmd = pkgs.callPackage ./pkgs/grpcmd { };
          kine = pkgs.callPackage ./pkgs/kine { };
          tc-redirect-tap = pkgs.callPackage ./pkgs/tc-redirect-tap { };

          goat = pkgs.callPackage ./pkgs/goat { };

          # non-free packages to cache in personal binary store
          terraform = pkgs.terraform;
          vault = pkgs.vault;
          vault-bin = pkgs.vault-bin;
          nomad = pkgs.nomad;
          nomad_1_8 = pkgs.nomad_1_8;
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
          update-packages = {
            type = "app";
            program = "${updatePackagesScript}/bin/update-packages";
          };
        };
      }
    );
}
