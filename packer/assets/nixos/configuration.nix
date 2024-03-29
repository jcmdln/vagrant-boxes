{ config, pkgs, ... }: {
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    curl
    dig
    git
    gnused
    inetutils
  ];

  networking.hostName = "nixos";

  programs = {
    dconf.enable = true;
    gnupg.agent.enable = true;
    mtr.enable = true;
  };

  security = {
    rtkit.enable = true;
    sudo.extraRules = [
      {
        users = [ "vagrant" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  services = {
    dbus.enable = true;
    openssh.enable = true;
    resolved.enable = true;
  };

  time.timeZone = "US/Eastern";

  users.users = {
    "vagrant" = {
      createHome = true;
      extraGroups = [ "wheel" ];
      initialPassword = "vagrant";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
      ];
      uid = 1000;
    };
  };

  zramSwap = {
    enable = true;
    memoryMax = 4 * 1024 * 1024 * 1024; # 4GiB
    memoryPercent = 25;
  };
}
