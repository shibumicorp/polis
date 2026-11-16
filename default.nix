{
  buildNpmPackage,
  lib,
  makeWrapper,
  nodejs,
}:
buildNpmPackage (final: {
    pname = "polis";
    version = "4.0.0";

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

    npmDepsHash = "sha256-IsPOc6bmMJfBxXaubfh9g8PVvSrQPn9JwfVi09dFby0=";

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