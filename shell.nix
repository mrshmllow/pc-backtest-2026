let
  npins = import ./npins;
  pkgs = import npins.nixpkgs { system = builtins.currentSystem; };
in
pkgs.mkShell {
  packages = [
    pkgs.cabal-install
    pkgs.haskell-language-server
    pkgs.haskellPackages.fourmolu
    pkgs.ghc
    pkgs.npins
    pkgs.zlib
    pkgs.pandoc

    (pkgs.runCommand "hlint" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir -p $out/bin
      cp ${pkgs.lib.getExe pkgs.haskellPackages.hlint} $out/bin/hlint
      wrapProgram $out/bin/hlint \
          --add-flag "--hint=${
            pkgs.fetchFromGitHub {
              owner = "kowainik";
              repo = "relude";
              rev = "5557fb226336855e4034a093f846fe9dd629c361";
              hash = "sha256-F/BJ0LXIxyzKd8QMesbwIzcLUn8EW1qZYm4uOAken9g=";
            }
          }/.hlint.yaml"
    '')
  ];

  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.zlib
  ];
}
