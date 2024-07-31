{
  description = "Unbound Redis Containers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { nixpkgs, systems, ... }:
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
                ];
              };
          });
    };
}
