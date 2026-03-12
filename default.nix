{
  buildNpmPackage,
  lib,
  makeWrapper,
  nodejs,
  noto-fonts,
  noto-fonts-cjk-sans,
  noto-fonts-color-emoji,
  corefonts,
  liberation_ttf,
  makeFontsConf,
}:
let
    myFonts = [
        corefonts
        liberation_ttf
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
    ];
    myFontsConf = makeFontsConf {
        fontDirectories = myFonts;
        impureFontDirectories = [];
        includes = [];
    };
in (buildNpmPackage (final: {
    pname = "polis";
    version = "1.52.2";

    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.difference
        ./.
        (lib.fileset.unions [
          ./default.nix
          ./flake.nix
          ./flake.lock
        ]);
    };

    npmDepsHash = "sha256-fQV7VnMVsA1O8DVB2gMrPFLi096qCNnw5YCWvQXcvzs=";

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        mkdir -p $out/share
        cp -R .next/standalone $out/share/polis
        makeWrapper ${nodejs}/bin/node $out/bin/polis \
            --add-flags server.js \
            --chdir $out/share/polis
        runHook postInstall
    '';
  }))
