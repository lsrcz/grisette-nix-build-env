{
  pkgs,
  ghcVersion,
  hfinal,
  extraTestToolDepends,
  ci,
  package,
  mixDirs,
}:
let
  versions = import ./hpkgs-versions.nix;
  copyMix =
    mixDir: "cp dist/build/${mixDir}/extra-compilation-artifacts/hpc/vanilla/mix/* $out/mix -r";
  copyAllMix = pkgs.lib.concatMapStringsSep "\n" copyMix mixDirs;
in
(pkgs.haskell.lib.overrideCabal package (
  drv:
  {
    testToolDepends = extraTestToolDepends ++ (drv.testToolDepends or [ ]);
  }
  // (
    if ci then
      {
        configureFlags = [
          "--flags=-optimize"
          "--enable-coverage"
          "--enable-library-coverage"
        ];
        postCheck =
          ''
            mkdir -p $out/test-report
            cp test-report.xml $out/test-report/test-report.xml
          ''
          + (
            if ghcVersion == versions.developmentGhcVersion then
              ''
                mkdir -p $out/mix
                cp dist/ $out/dist -r
                ${copyAllMix}
                mkdir -p $out/tix
                find dist/hpc/vanilla/tix -name '*.tix' | xargs -I {} cp {} $out/tix -r
              ''
            else
              ""
          );
        haddockFlags = [
          "--html-location='https://hackage.haskell.org/package/\$pkg-\$version/docs'"
        ];
        postHaddock = ''
          mkdir -p $out
          cp -r dist/doc/ $out/haddock -r
        '';
      }
    else
      { }
  )
)).overrideAttrs
  (
    if ci then
      {
        checkFlags = [
          "--test-options=--jxml=test-report.xml"
        ];
      }
    else
      { }
  )
