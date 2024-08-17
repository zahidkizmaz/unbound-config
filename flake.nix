{
  description = "Unbound Redis Containers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      nixosModules = {
        recursive_dns = import ./docker-compose.nix;
        default = self.nixosModules.recursive_dns;
      };

      devShells = eachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default =
              pkgs.mkShell {
                packages = [
                  pkgs.nixd
                  pkgs.nixpkgs-fmt
                ];
              };
          });
    };
}
