# techknow's bargin basement collection of packages

Packages that I need for one off reasons, or that I don't have the time to maintain properly for nixpkgs.
The repo name "bargin basement" is not a reflection of the software that is included, but rather of
techknows's effort in packaging them.

## Usage

There are multiple ways to utilize this flake, you could import it in your own flake, and use the packages
as inputs, or you could run them ad-hoc via the command line.

### Importing the packages in your flake

Add the following as an input for your flake:

```nix
tpkgs = {
    url = "git+https://gitea.com/techknowlogick/tklk-flake";
    inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list for their inputs
};
```

then, you can use `tpkgs.packages.${pkgs.system}.<package-name>` to access the packages.

### Running via command line

You can also run the packages via command line in an ad-hoc manner:

```sh
# for most packages, where the package name is the same as the CLI name you can use nix run
nix run git+https://gitea.com/techknowlogick/tklk-flake#terraform -- --version

# for packages where the package name is different than the CLI name, you can use nix shell, and -c
nix shell git+https://gitea.com/techknowlogick/tklk-flake#httpie -c https -vv pie.dev/get
```

## LICENSE

All packages in this repository are licensed under the AGPL3 license.
I'm the only contributor to this repo, so if for some reason you need a different license, please contact me.
