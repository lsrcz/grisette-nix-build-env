{
  pkgs,
  devShellWithVersion,
  haskellPackagesWithCiFlags,
  packageName,
}:
let
  hpkgsVersions = import ./hpkgs-versions.nix;
in
pkgs.lib.foldl' (
  acc: ghcVersion:
  pkgs.lib.recursiveUpdate acc {
    devShells.${ghcVersion} = devShellWithVersion { ghcVersion = ghcVersion; };
    packages.${packageName} = {
      "${ghcVersion}" =
        (haskellPackagesWithCiFlags {
          ghcVersion = ghcVersion;
          ci = false;
        }).${packageName};
      "${ghcVersion}-ci" =
        (haskellPackagesWithCiFlags {
          ghcVersion = ghcVersion;
          ci = true;
        }).${packageName};
    };
  }
) { } hpkgsVersions.supportedGhcVersions
