{
  description = ''
    techknow's bargin basement collection of packages

    packages that I need for one off reasons, or that I don't
    have the time to maintain properly for nixpkgs.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;

          # some of the python packages need to be included as an overlay to be imported correctly
          overlays = [
            (self: super: {
              urllib3-future = super.python3Packages.callPackage ./pkgs/urllib3-future { };
              wassima = super.python3Packages.callPackage ./pkgs/wassima { };
              jh2 = super.python3Packages.callPackage ./pkgs/jh2 { };
              qh3 = super.python3Packages.callPackage ./pkgs/qh3 { };
              niquests = super.python3Packages.callPackage ./pkgs/niquests { };
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

          cilium-cni = pkgs.callPackage ./pkgs/cilium-cni { };
          grpcmd = pkgs.callPackage ./pkgs/grpcmd { };
          kine = pkgs.callPackage ./pkgs/kine { };

          # pending merge of PR: https://github.com/NixOS/nixpkgs/pull/330775
          nomad-driver-containerd = pkgs.callPackage ./pkgs/nomad-driver-containerd { };
        };
      }
    );
}
