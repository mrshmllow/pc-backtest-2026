let
  npins = import ./npins;
  pkgs = import npins.nixpkgs { system = builtins.currentSystem; };
in
pkgs.mkShell {
  packages = [
    pkgs.cabal-install
    pkgs.ghc
    pkgs.npins
  ];
}
