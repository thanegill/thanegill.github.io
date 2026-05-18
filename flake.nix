{
  description = "thanegill.com — Pelican static site";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        { config, pkgs, ... }:
        let
          python = pkgs.python3;
          jinja2content = python.pkgs.callPackage ./nix/jinja2content { };
          html-validate = pkgs.callPackage ./nix/html-validate { };
          pythonEnv = python.withPackages (ps: with ps; [
            pelican
            markdown
            livereload
            jinja2content
          ]);

          devScript = pkgs.writeShellApplication {
            name = "pelican-serve";
            runtimeInputs = [ pythonEnv ];
            text = ''
              exec pelican --autoreload --listen "$@"
            '';
          };

        in
        {
          checks = {
            html-validate = pkgs.runCommand "html-validate" { nativeBuildInputs = [ html-validate ]; } ''
              html-validate --config ${self}/linters/htmlvalidate.json ${config.packages.default}/**/*.html
              touch $out
            '';

            lychee = pkgs.runCommand "lychee" { nativeBuildInputs = [ pkgs.lychee ]; } ''
              lychee --config ${self}/linters/lychee.toml --root-dir ${config.packages.default} ${config.packages.default}/**/*.html
              touch $out
            '';

            djlint = pkgs.runCommand "djlint" { nativeBuildInputs = [ pkgs.djlint ]; } ''
              djlint --configuration ${self}/linters/djlintrc ${self}/themes/clean-blog/templates --lint
              touch $out
            '';

            markdownlint = pkgs.runCommand "markdownlint" { nativeBuildInputs = [ pkgs.markdownlint-cli ]; } ''
              markdownlint --config ${self}/linters/markdownlint.json ${self}/content
              touch $out
            '';
          };

          packages = {
            default = pkgs.stdenv.mkDerivation {
              name = "thanegill-github-io";
              src = ./.;
              nativeBuildInputs = [ pythonEnv ];
              buildPhase = ''
                pelican content -o output -s pelicanconf.py
              '';
              installPhase = ''
                cp -r output $out
              '';
            };
            html-validate = html-validate;
            inherit jinja2content;
          };

          apps.default = {
            type = "app";
            program = "${devScript}/bin/pelican-serve";
          };

          devShells.default = pkgs.mkShell {
            packages = [
              pythonEnv
              pkgs.djlint
              pkgs.markdownlint-cli
              pkgs.lychee
              html-validate
              pkgs.stylelint
            ];
            shellHook = ''
              echo "Pelican dev environment"
              echo "  nix run             # autoreload dev server (port 8000)"
              echo "  pelican content     # build to output/"
            '';
          };
        };
    };
}
