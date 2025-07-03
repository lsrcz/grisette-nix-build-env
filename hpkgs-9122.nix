{ pkgs }:
with pkgs.haskell.lib;
(import ./hpkgs-base.nix {
  inherit pkgs;
  ghcVersion = "9122";
}).extend
  (
    hfinal: hprev: {
      sbv = dontCheck (hfinal.callHackage "sbv" "11.7" { });
    }
  )
