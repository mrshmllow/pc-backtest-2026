let
  npins = import ./npins;
  pkgs = import npins.nixpkgs { system = builtins.currentSystem; };
in
pkgs.mkShell {
  packages = [
    pkgs.cabal-install
    pkgs.haskell-language-server
    pkgs.haskellPackages.hlint
    pkgs.haskellPackages.fourmolu
    pkgs.ghc
    pkgs.npins
    pkgs.zlib
    pkgs.hlint
    pkgs.pandoc
  ];

  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.zlib
  ];
}
