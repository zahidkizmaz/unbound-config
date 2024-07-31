# Auto-generated using compose2nix v0.2.1-pre.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";

  networking.firewall.allowedTCPPorts = [ 8553 ];

  # Containers
  virtualisation.oci-containers.containers."unbound" = {
    image = "docker.io/crazymax/unbound@sha256:a820c63d07fbd863f1863d5af001c330d6cff5bdcc70ad78d503377e6b1ce69e";
    volumes = [
      "config:/config:ro"
    ];
    ports = [
      "8553:5053/tcp"
      "8553:5053/udp"
    ];
    dependsOn = [
      "unbound-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=unbound"
      "--network=unbound_default"
    ];
  };
  systemd.services."podman-unbound" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-unbound_default.service"
    ];
    requires = [
      "podman-network-unbound_default.service"
    ];
    partOf = [
      "podman-compose-unbound-root.target"
    ];
    wantedBy = [
      "podman-compose-unbound-root.target"
    ];
  };
  virtualisation.oci-containers.containers."unbound-redis" = {
    image = "docker.io/redis:7.2-alpine@sha256:0bc09d9f486508aa42ecc2f18012bb1e3a1b2744ef3a6ad30942fa12579f0b03";
    volumes = [
      "redis:/data:rw"
    ];
    cmd = [ "redis-server" "--save" "43200" "1" "7200" "100" "--loglevel" "debug" "--rdbchecksum" "no" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=redis"
      "--network=unbound_default"
    ];
  };
  systemd.services."podman-unbound-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-unbound_default.service"
    ];
    requires = [
      "podman-network-unbound_default.service"
    ];
    partOf = [
      "podman-compose-unbound-root.target"
    ];
    wantedBy = [
      "podman-compose-unbound-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-unbound_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f unbound_default";
    };
    script = ''
      podman network inspect unbound_default || podman network create unbound_default
    '';
    partOf = [ "podman-compose-unbound-root.target" ];
    wantedBy = [ "podman-compose-unbound-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-unbound-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
