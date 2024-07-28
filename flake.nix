{
  description = "Unbound Redis Containers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { nixpkgs }:
    {
      packages = {
        default = nixpkgs.lib.mkShell {
          buildInputs = [
            (import ./docker-compose.nix)
          ];
        };
      };
    };
}
