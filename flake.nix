{
  description = "Polis";

  inputs.build-support.url = "github:ShibumiCorp/build_support";
  inputs.nixpkgs.follows = "build-support/nixpkgs";
  inputs.flake-parts.follows = "build-support/flake-parts";
  # Separate nixpkgs for node so we can track a newer release than build-support.
  inputs.nixpkgs-node.url = "github:NixOS/nixpkgs/nixos-26.05-small";

  outputs = inputs@{ flake-parts, nixpkgs-node, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({...}: {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
      ];

      perSystem = {pkgs, system, ...}:
        let
          nodejs = nixpkgs-node.legacyPackages.${system}.nodejs_26;
          polis = pkgs.callPackage ./default.nix { inherit nodejs; };
        in {
          packages = {
            default = polis;
            bin = polis;
            docker = pkgs.callPackage ./docker.nix { inherit polis; };
          };

          devShells = {
            default = pkgs.mkShell {
              name = "snapshot-service";
              buildInputs = [
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
