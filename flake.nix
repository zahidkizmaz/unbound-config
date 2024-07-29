{
  description = "Unbound Redis Containers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    compose2nix.url = "github:aksiksi/compose2nix";
    systems.url = "github:nix-systems/default";
  };

  outputs = { nixpkgs, systems, compose2nix, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      lib.dns = import ./docker-compose.nix;
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
                  compose2nix.packages.${system}.default
                ];
              };
          });
    };
}
