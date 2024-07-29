{
  description = "Unbound Redis Containers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    compose2nix.url = "github:aksiksi/compose2nix";
  };

  outputs = { self, nixpkgs, flake-utils, compose2nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        nixosModules.dns = import ./docker-compose.nix;
        nixosModules.default = self.nixosModules.dns;

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nixd
            pkgs.nixpkgs-fmt
            compose2nix.packages.${system}.default
          ];
        };
      });
}
