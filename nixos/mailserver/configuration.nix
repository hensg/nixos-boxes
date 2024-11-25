{ modulesPath
, pkgs
, ...
}:
let
  inherit ((import ../../authorized-keys/keys.nix)) authorizedKeys;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./encrypted-disks.nix
    ./mail.nix
  ];

  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        enableCryptodisk = true;
      };
    };

    initrd = {
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
        "sr_mod"
      ];

      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          ignoreEmptyHostKeys = true;
          inherit authorizedKeys;
        };
        postCommands = ''
          echo 'cryptsetup-askpass' >> /root/.profile
        '';
      };
    };
  };
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = " 24.05 ";
}
