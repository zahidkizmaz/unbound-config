# Unbound - Redis

## Dev

Generate docker-compose.nix via:

```shell
nix run github:aksiksi/compose2nix -- -project=unbound -root_path=.
```

OR

```shell
nix develop
compose2nix -project=unbound -root_path=.
```
