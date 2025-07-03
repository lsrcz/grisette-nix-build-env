{ pkgs, ghcVersion }:
({
  "8107" = import ./hpkgs-8107.nix { inherit pkgs; };
  "902" = import ./hpkgs-902.nix { inherit pkgs; };
  "928" = import ./hpkgs-928.nix { inherit pkgs; };
  "948" = import ./hpkgs-948.nix { inherit pkgs; };
  "966" = import ./hpkgs-966.nix { inherit pkgs; };
  "984" = import ./hpkgs-984.nix { inherit pkgs; };
  "9102" = import ./hpkgs-9102.nix { inherit pkgs; };
  "9122" = import ./hpkgs-9122.nix { inherit pkgs; };
})."${ghcVersion}"
