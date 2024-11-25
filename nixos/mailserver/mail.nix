{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    swaks
    inetutils
    mailutils
    bind
  ];
  sops.defaultSopsFile = ../../secrets/mailserver.yaml;
  sops.secrets.pass = { };
  # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'

  mailserver = {
    enable = true;
    fqdn = "mail.hensg.dev";
    domains = [ "hensg.dev" ];
    dmarcReporting = {
      enable = true;
      domain = "hensg.dev";
      organizationName = "hensg";
    };
    dkimKeyBits = 1535;

    loginAccounts = {
      "me@hensg.dev" = {
        name = "me@hensg.dev";
        hashedPasswordFile = "/run/secrets/pass";
        aliases = [ "me@hensg.dev" "postmaster@hensg.dev" ];
        catchAll = [ "hensg.dev" ];
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "me@hensg.dev";

  networking = {
    hostName = "mail";
    nftables.enable = true;
    firewall = {
      enable = true;
      checkReversePath = "loose";
      allowedTCPPorts = [ 25 26 465 993 ];
    };
    hosts = {
      "127.0.0.1" = [ "mail.hensg.dev" ];
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
  services.fail2ban.enable = true;
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
    dnsovertls = "true";
  };
}
