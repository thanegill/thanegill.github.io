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
        html-validate = pkgs.callPackage ./nix/html-validate { };
        pythonEnv = python.withPackages (ps: [ ps.pelican ps.markdown ps.livereload jinja2content ]);

        site = pkgs.stdenv.mkDerivation {
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

        devScript = pkgs.writeShellApplication {
          name = "pelican-serve";
          runtimeInputs = [ pythonEnv ];
          text = ''
            exec pelican --autoreload --listen "$@"
          '';
        };
      in {
        checks.html-validate = pkgs.runCommand "html-validate" {
          nativeBuildInputs = [ html-validate ];
        } ''
          html-validate --config ${self}/.htmlvalidate.json ${site}/**/*.html
          touch $out
        '';

        checks.lychee = pkgs.runCommand "lychee" {
          nativeBuildInputs = [ pkgs.lychee ];
        } ''
          lychee --config ${self}/.lychee.toml --root-dir ${site} ${site}/**/*.html
          touch $out
        '';

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

        packages.html-validate = html-validate;
        packages.pelican-jinja2content = jinja2content;
        packages.default = site;

        apps.default = {
          type = "app";
          program = "${devScript}/bin/pelican-serve";
        };

        devShells.default = pkgs.mkShell {
          packages = [ pythonEnv pkgs.djlint pkgs.markdownlint-cli pkgs.lychee html-validate pkgs.stylelint ];
          shellHook = ''
            echo "Pelican dev environment"
            echo "  nix run             # autoreload dev server (port 8000)"
            echo "  pelican content     # build to output/"
          '';
        };
      });
}
