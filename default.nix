{
  buildNpmPackage,
  lib,
  makeWrapper,
  nodejs,
}:
buildNpmPackage (final: {
    pname = "polis";
    version = "3.0.0";

    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.difference
        ./.
        (lib.fileset.unions [
          ./default.nix
          ./docker.nix
          ./flake.nix
          ./flake.lock
        ]);
    };

    # Use the same node for npm ci / next build as at runtime.
    inherit nodejs;

    npmDepsHash = "sha256-KoVc/PbJJYcpZoxx6Jk4HcLFQ2HFIGznyfXxyoBeE5M=";

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
  })