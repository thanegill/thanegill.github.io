{
  description = "thanegill.com — Pelican static site";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python3;
        pelican = python.pkgs.pelican;
        markdown = python.pkgs.markdown;
        livereload = python.pkgs.livereload;

        devScript = pkgs.writeShellApplication {
          name = "pelican-serve";
          runtimeInputs = [ pelican markdown livereload ];
          text = ''
            exec pelican --autoreload --listen "$@"
          '';
        };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "thanegill-github-io";
          src = ./.;
          nativeBuildInputs = [ pelican markdown ];
          buildPhase = ''
            export PYTHONPATH=$PWD:$PYTHONPATH
            pelican content -o output -s pelicanconf.py
          '';
          installPhase = ''
            cp -r output $out
          '';
        };

        apps.default = {
          type = "app";
          program = "${devScript}/bin/pelican-serve";
        };

        devShells.default = pkgs.mkShell {
          packages = [ pelican markdown livereload ];
          shellHook = ''
            echo "Pelican dev environment"
            echo "  nix run             # autoreload dev server (port 8000)"
            echo "  pelican content     # build to output/"
          '';
        };
      });
}
