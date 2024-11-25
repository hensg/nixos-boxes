{ modulesPath
, pkgs
, hugo-site
, system
, ...
}:
let
  keys = (import ../../authorized-keys/keys.nix).authorizedKeys;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk.nix
  ];

  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        enableCryptodisk = true;
        device = "/dev/sda";
      };
    };

    initrd = {
      availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
    };
  };

  services.resolved.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    gitMinimal
    neovim
    hugo-site.packages.${system}.website
  ];

  users.users.root.openssh.authorizedKeys.keys = keys;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    allowSFTP = false;
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    enable = true;
  };


  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    virtualHosts."hensg.dev" = {
      root = "${hugo-site.packages.${system}.website}";

      forceSSL = true;
      enableACME = true;

      locations."/" = { };
      locations."/robots.txt" = {
        extraConfig = ''
          rewrite ^/(.*)  $1;
          return 200 "User-agent: *\nDisallow: /";
        '';
      };
    };

    commonHttpConfig =
      let
        realIpsFromList = pkgs.lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
        fileToList = x: pkgs.lib.strings.splitString "\n" (builtins.readFile x);
        cfipv4 = fileToList (pkgs.fetchurl {
          url = "https://www.cloudflare.com/ips-v4";
          sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
        });
        cfipv6 = fileToList (pkgs.fetchurl {
          url = "https://www.cloudflare.com/ips-v6";
          sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
        });
      in
      ''
        ${realIpsFromList cfipv4}
        ${realIpsFromList cfipv6}
        real_ip_header CF-Connecting-IP;
      '';
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "hensg.dev".email = "henriquedsg89@gmail.com";
    };
  };

  system.stateVersion = " 24.05 ";
}
