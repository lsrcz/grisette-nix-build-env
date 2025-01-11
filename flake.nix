{
  description = "Build environment for grisette";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      pre-commit-hooks,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        treefmt = treefmt-nix.lib.mkWrapper pkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          settings.formatter.nixfmt.excludes = [ ".direnv" ];
        };

        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            treefmt.enable = true;
            treefmt.package = treefmt;
          };
        };
      in
      {
        checks = {
          pre-commit-check = pre-commit-check;
        };
        formatter = treefmt;
        lib = import ./. {
          default-treefmt-nix = treefmt-nix;
          default-pre-commit-hooks = pre-commit-hooks;
        };
        devShell = pkgs.mkShell {
          shellHook = pre-commit-check.shellHook;
        };
      }
    );
}
