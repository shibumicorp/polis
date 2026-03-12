{
  description = "Polis";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      eachSystem = nixpkgs.lib.genAttrs systems;
      pkgsFor = eachSystem (system:
        import nixpkgs {
          localSystem.system = system;
          config.allowUnfree = true;
          overlays = [self.overlays.default];
        });
    in {
      overlays = {
        default = final: prev: {
          polis = final.callPackage ./default.nix {};
          docker-cacert = prev.cacert;
        };
      };

      packages = eachSystem (system: let pkgs = pkgsFor.${system}; in {
        default = pkgs.polis;
        bin = pkgs.polis;
        docker = pkgs.callPackage ./docker.nix {};
      });

      devShells = eachSystem(system:
        let pkgs = pkgsFor.${system};
        in {
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
        });
    };
}
