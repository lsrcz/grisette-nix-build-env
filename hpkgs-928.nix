{ pkgs }:
with pkgs.haskell.lib;
(import ./hpkgs-base.nix {
  inherit pkgs;
  ghcVersion = "928";
}).extend
  (
    hfinal: hprev: {
      sbv = dontCheck (hfinal.callHackage "sbv" "10.10" { });
      Chart-cairo = hfinal.callHackage "Chart-cairo" "1.9.3" { };
    }
  )
