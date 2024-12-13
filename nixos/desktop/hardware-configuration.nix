# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "dm-crypt" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "uvcvideo" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/cbe6422e-477b-4c01-8f90-191be5df86d6";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/AF34-C5CF";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/var/lib/bitcoind" =
    {
      device = "/dev/disk/by-uuid/be4b2ee1-75f6-4e1c-995f-d5253e1aafc9";
      fsType = "ext4";
    };

  swapDevices = [ ];

  boot.initrd.luks.devices = {
    "encrypted-backups" = {
      device = "/dev/disk/by-id/ata-ST4000DM004-2CV104_ZTT17QY8";
    };
    "encrypted-home" = {
      device = "/dev/disk/by-id/nvme-KINGSTON_SNV2S1000G_50026B7686E54AE2";
    };
  };

  fileSystems."/mnt/backups" = {
    device = "/dev/mapper/encrypted-backups";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/mapper/encrypted-home";
    fsType = "ext4";
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  #networking.useDHCP = lib.mkDefault true;
  #networking.interfaces.eno2.useDHCP = lib.mkDefault true;
  #networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
