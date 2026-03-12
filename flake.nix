{
  description = "Polis";

  inputs.build-support.url = "github:ShibumiCorp/build_support";
  inputs.nixpkgs.follows = "build-support/nixpkgs";
  inputs.flake-parts.follows = "build-support/flake-parts";

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({...}: {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {pkgs, ...}:
        let polis = pkgs.callPackage ./default.nix {};
        in {
          packages = {
            default = polis;
            bin = polis;
            docker = pkgs.callPackage ./docker.nix { inherit polis; };
          };

          devShells = {
            default = pkgs.mkShell {
              name = "snapshot-service";
              buildInputs = with pkgs; [
                nodejs
              ];
              nativeBuildInputs = with pkgs; [
                nodePackages.typescript-language-server
                vscode-langservers-extracted
              ];
            };
          };
        };
    });
}
