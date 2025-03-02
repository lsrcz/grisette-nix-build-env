{ default-treefmt-nix }:
{
  pkgs,
  treefmt-nix ? default-treefmt-nix,
  excludes ? [ ],
}:
treefmt-nix.lib.mkWrapper pkgs {
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.ormolu.enable = true;
  programs.ormolu.package =
    (import ./hpkgs-base.nix {
      inherit pkgs;
      ghcVersion = "9101";
    }).ormolu;
  programs.yamlfmt.enable = true;
  programs.mdformat.enable = true;
  programs.mdformat.package = pkgs.mdformat.withPlugins (
    ps: with ps; [
      (buildPythonPackage rec {
        pname = "mdformat_myst";
        version = "0.2.1";
        src = fetchPypi {
          inherit pname version;
          sha256 = "sha256-tF679zx4xCvWBZxu2RAXBIhHemKFhwVh33rJ14KXh4Q=";
        };
        pyproject = true;
        nativeBuildInputs = [ flit-core ];
        propagatedBuildInputs = [
          mdformat
          mdformat-tables
          mdformat-frontmatter
          mdformat-footnote
          ruamel-yaml
          myst-parser
        ];
      })
    ]
  );
  programs.mdformat.settings.wrap = 80;
  programs.hlint.enable = true;
  settings.formatter.nixfmt.excludes = [ ".direnv" ];
  settings.formatter.ormolu.includes = [
    "*.hs"
    "*.hs-boot"
    "*.lhs"
  ];
  settings.excludes = excludes ++ [
    "LICENSE"
    "*.lock"
    "**/*.cabal"
    "*.cabal"
    "cabal.project"
    ".gitignore"
  ];
}
