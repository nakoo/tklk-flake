# techknow's bargin basement collection of packages

packages that I need for one off reasons, or that I don't have the time to maintain properly for nixpkgs.

## Usage

Add the following as an input for your flake:

```nix
tpkgs = {
    url = "git+https://gitea.com/techknowlogick/tklk-flake";
    inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list for their inputs
};
```

## LICENSE

All packages in this repository are licensed under the AGPL3 license.
I'm the only contributor to this repo, so if for some reason you need a different license, please contact me.
