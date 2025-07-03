{ pkgs, ghcVersion }:
pkgs.haskell.packages."ghc${ghcVersion}".override (prev: {
  all-cabal-hashes = pkgs.fetchFromGitHub {
    owner = "commercialhaskell";
    repo = "all-cabal-hashes";
    rev = "8644ed27bb9149ea18ea46f59ecfaf1edb83fdeb";
    sha256 = "sha256-qd4n7LttO5GjWTVuwKKM5r0cqB9qD+fkXCkoSYc0hhg=";
  };
})
