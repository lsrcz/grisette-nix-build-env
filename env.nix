{
  nixpkgs,
  system,
  treefmt-nix,
  pre-commit-hooks,
  srcRoot,
  extraHaskellPackages,
  pname,
  extraOutputs,
  extraOverlays ? [ ],
  treefmtExcludes ? [ ],
  devShellExtraBuildInputs ? _: _: [ ],
  defaultDevShellExtraBuildInputsConfig ? ({
    isDevelopmentEnvironment = false;
  }),
}:
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = extraOverlays ++ [
      (import ./cvc5-overlay.nix)
      (import ./hlint-src-overlay.nix)
      (import ./z3-overlay.nix)
    ];
  };

  basicHaskellPackages =
    ghcVersion:
    import ./hpkgs.nix {
      inherit pkgs ghcVersion;
    };

  haskellPackages =
    { ghcVersion, ci }:
    (basicHaskellPackages ghcVersion).extend (
      hfinal: hprev:
      extraHaskellPackages pkgs ghcVersion hfinal
        (import ./hpkgs-extend-helpers.nix {
          inherit
            pkgs
            hfinal
            hprev
            ghcVersion
            ;
        })
        (
          {
            extraTestToolDepends,
            mixDirs,
            package,
          }:
          (import ./set-ci-options.nix) {
            inherit
              pkgs
              ghcVersion
              hfinal
              ci
              ;
            extraTestToolDepends = extraTestToolDepends;
            mixDirs = mixDirs;
            package = package;
          }
        )
    );
  treefmt = (
    import ./treefmt.nix { default-treefmt-nix = treefmt-nix; } {
      inherit pkgs;
      excludes = treefmtExcludes;
    }
  );

  pre-commit-check = (
    import ./hook.nix { default-pre-commit-hooks = pre-commit-hooks; } {
      src = srcRoot;
      inherit treefmt system;
    }
  );

  devShellWithVersion =
    {
      ghcVersion,
      config ? defaultDevShellExtraBuildInputsConfig,
    }:
    ((import ./dev-shells.nix) {
      inherit pkgs;
      inherit (config) isDevelopmentEnvironment;
      haskellPackages = basicHaskellPackages ghcVersion;
      extraBuildInputs = devShellExtraBuildInputs pkgs config;
    }).overrideAttrs
      (old: {
        shellHook = pre-commit-check.shellHook;
      });

  plainOutputs = (import ./default-outputs.nix) {
    inherit pkgs devShellWithVersion;
    haskellPackagesWithCiFlags = haskellPackages;
    packageName = pname;
  };

  package =
    (haskellPackages {
      ghcVersion = (import ./hpkgs-versions.nix).developmentGhcVersion;
      ci = false;
    }).${pname};

in
pkgs.lib.recursiveUpdate (pkgs.lib.recursiveUpdate plainOutputs {
  formatter = treefmt;

  checks = {
    pre-commit-check = pre-commit-check;
  };

  packages."${pname}" = package;
  packages.default = package;
}) (extraOutputs pkgs haskellPackages devShellWithVersion)
