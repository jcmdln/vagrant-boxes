{ config, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [ "ahci" "sd_mod" "sr_mod" "virtio_pci" "virtio_scsi" ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=root" ];
    };

    "/home" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=home" ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "noatime" "compress=zstd" "subvol=nix" ];
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
  };

  networking.useDHCP = lib.mkDefault true;
  system.stateVersion = "22.05";
}
