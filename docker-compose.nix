{ pkgs, ... }:

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

  environment.systemPackages = [ pkgs.podman-compose ];

  networking.firewall.allowedTCPPorts = [ 8553 ];

  systemd.services.unbound-compose = {
    path = with pkgs; [ podman podman-compose ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman-compose -f ./docker-compose.yml down";
    };
    script = ''
      podman-compose -f ./docker-compose.yml up
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "podman.service" "podman.socket" ];
  };
}
