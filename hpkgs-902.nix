{ pkgs }:
with pkgs.haskell.lib;
(import ./hpkgs-base.nix {
  inherit pkgs;
  ghcVersion = "902";
}).extend
  (
    hfinal: hprev: {
      sbv = dontCheck (hfinal.callHackage "sbv" "9.2" { });
      Chart-cairo = hfinal.callHackage "Chart-cairo" "1.9.3" { };
    }
  )
