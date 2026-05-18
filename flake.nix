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
        jinja2content = python.pkgs.callPackage ./nix/pelican-jinja2content { };
        pythonEnv = python.withPackages (ps: [ ps.pelican ps.markdown ps.livereload jinja2content ]);

        devScript = pkgs.writeShellApplication {
          name = "pelican-serve";
          runtimeInputs = [ pythonEnv ];
          text = ''
            exec pelican --autoreload --listen "$@"
          '';
        };
      in {
        checks.djlint = pkgs.runCommand "djlint" {
          nativeBuildInputs = [ pkgs.djlint ];
        } ''
          cd ${self} && djlint themes/clean-blog/templates --lint
          touch $out
        '';

        checks.markdownlint = pkgs.runCommand "markdownlint" {
          nativeBuildInputs = [ pkgs.markdownlint-cli ];
        } ''
          markdownlint --config ${self}/.markdownlint.json ${self}/content
          touch $out
        '';

        packages.pelican-jinja2content = jinja2content;
        packages.default = pkgs.stdenv.mkDerivation {
          name = "thanegill-github-io";
          src = ./.;
          nativeBuildInputs = [ pythonEnv ];
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
          packages = [ pythonEnv pkgs.djlint pkgs.markdownlint-cli ];
          shellHook = ''
            echo "Pelican dev environment"
            echo "  nix run             # autoreload dev server (port 8000)"
            echo "  pelican content     # build to output/"
          '';
        };
      });
}
