{ pkgs, ... }:
let
  inherit ((import ../../authorized-keys/keys.nix)) authorizedKeys;
in
{
  networking = {
    useHostResolvConf = false;
    firewall.checkReversePath = "loose";
    nameservers = [
      "127.0.0.1"
      "::1"
    ];
  };

  users.users.henrique.openssh.authorizedKeys.keys = authorizedKeys;

  environment.systemPackages = with pkgs;[
    tailscale
    mullvad
    mullvad-vpn
    wireguard-tools
  ];

  services = {
    fail2ban.enable = true;

    mullvad-vpn.enable = true;

    openssh = {
      enable = true;
      settings = {
        AllowAgentForwarding = true;
        PermitUserEnvironment = true;
        StreamLocalBindUnlink = true;
        AcceptEnv = "SSH_AUTH_SOCK";
      };
    };

    ntp.enable = true;

    syncthing = {
      enable = true;
      user = "henrique";
      dataDir = "/home/henrique/cyber-shared"; # Default folder for new synced folders
      configDir = "/home/henrique/.config/syncthing"; # Folder for Syncthing's settings and keys
    };

    dnscrypt-proxy2 = {
      enable = true;
      settings = {
        ipv6_servers = true;
        require_dnssec = true;
        listen_addresses = [ "127.0.0.1:53" ];
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/tmp/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };
      };
    };
  };
}
