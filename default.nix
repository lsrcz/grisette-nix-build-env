{ default-treefmt-nix, default-pre-commit-hooks }:
let
  hpkgsVersions = import ./hpkgs-versions.nix;
in
{
  overlays = {
    z3 = import ./z3-overlay.nix;
    hlintSrc = import ./hlint-src-overlay.nix;
    cvc5 = import ./cvc5-overlay.nix;
  };
  patchedHaskellPackages = import ./hpkgs.nix;
  haskellPackagesExtendHelpers = import ./hpkgs-extend-helpers.nix;
  devShell = import ./dev-shells.nix;
  setCIOptions = import ./set-ci-options.nix;
  developmentGhcVersion = hpkgsVersions.developmentGhcVersion;
  supportedGhcVersions = hpkgsVersions.supportedGhcVersions;
  defaultOutputs = import ./default-outputs.nix;
  treefmt = import ./treefmt.nix {
    inherit default-treefmt-nix;
  };
  pre-commit-check = import ./hook.nix {
    inherit default-pre-commit-hooks;
  };
  output =
    input:
    (import ./env.nix) (
      input
      // {
        treefmt-nix = default-treefmt-nix;
        pre-commit-hooks = default-pre-commit-hooks;
      }
    );
}
