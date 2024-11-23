{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.callPackage ./package.nix { };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            clang
            gcc
            gnumake
            SDL2.dev
            (python312.withPackages (ps: with ps; [ pillow pyyaml ]))
          ];
        };
      });
}
