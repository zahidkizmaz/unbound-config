{ pkgs, ... }:

let
  configFile = ./config/unbound.conf;
  composeFilePath = ./docker-compose.yml;
  podmanPath = "${pkgs.podman}/bin/podman";
  podmanComposePath = "${pkgs.podman-compose}/bin/podman-compose";
  environment.etc = {
    unbound.conf =
      {
        source = "${configFile}";
      };
  };
in
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

  networking.firewall.allowedTCPPorts = [ 8553 6379 ];

  systemd.services.unbound-compose = {
    path = with pkgs; [ podman podman-compose ];
    serviceConfig = {
      Restart = "always";
      RemainAfterExit = true;
      ExecStartPre = [
        "${podmanPath} pod rm -f pod_store || true"
        "${podmanComposePath} --verbose -f ${composeFilePath} build"
      ];
      ExecStart = "${podmanComposePath} -f ${composeFilePath} up";
      ExecStop = "${podmanComposePath} -f ${composeFilePath} down";
    };
    wantedBy = [ "multi-user.target" ];
    after = [ "podman.service" "podman.socket" ];
    requires = [ "podman.service" "podman.socket" ];
  };
}
