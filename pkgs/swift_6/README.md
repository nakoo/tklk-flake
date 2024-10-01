# Swift 6

This is a near complete copy of nixpkgs, except updated to build with Swift 6. This folder specifically is licensed under he terms of nixpkgs, including the modifications to update to Swift 6. A big thank you to the maintainers of swift in nixpkgs as they have done a lot of the heavy lifting to get swift building in nixpkgs, and it is really appreciated.

The reason why this is included here, vs being contributed back to nixpkgs, is that Swift 6 requires a swift compiler already built to build the swift toolchain. Additional bootstrapping is needed to get this into nixpkgs, and my focus is getting some swift projects built, vs figuring out how best to contribute this back to nixpkgs (without significant duplication).
