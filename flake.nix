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
                propagatedBuildInputs = oldAttrs.propagatedBuildInputs or [ ] ++ [ super.niquests ];
                disabledTests = oldAttrs.disabledTests or [ ] ++ [
                  "test_config_dir_is_created"
                  "test_incomplete_response"
                  "test_main_entry_point"
                  "test_daemon_runner"
                ];
                src = super.fetchFromGitHub {
                  owner = "Ousret";
                  repo = "httpie";
                  rev = "2e3617ecdbc8cabab404fe3133ae671df8579b04";
                  hash = "sha256-4TiItfVVJr6uJO8GtjN52NysWzwSJ2+l/Uh1mFE9cx0=";
                };
              });
            })
          ];
        };
        pythonPackages = pkgs.python3Packages;
      in
      {
        packages = {
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

          sublimetext4 = pkgs.callPackage ./pkgs/sublimetext4 { };
          sublimetext4-dev = pkgs.callPackage ./pkgs/sublimetext4 { dev = true; };

          # pre-build attic binaries
          attic = attic.packages.${system}.attic;
          attic-client = attic.packages.${system}.attic-client;
          attic-server = attic.packages.${system}.attic-server;
        };
      }
    );
}
