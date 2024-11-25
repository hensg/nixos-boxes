{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gnupg
    yubikey-personalization
    yubikey-manager
    pam_u2f
    yubico-pam
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
    libu2f-host
  ];

  programs.ssh.startAgent = false;
  hardware.gpgSmartcards.enable = true;
  services.pcscd.enable = true;

  security.pam.services = {
    login.u2fAuth = true;
    sudo = {
      u2fAuth = true;
    };
  };

  #security.pam.yubico = {
  #  enable = true;
  #  debug = true;
  #  mode = "challenge-response";
  #  id = [ "25331213" ];
  #};

  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
  environment.shellInit = ''
    gpg-connect-agent /bye
    export GPG_TTY="$(tty)"
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

}
