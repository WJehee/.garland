{ inputs, lib, config, pkgs, ... }:
{
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
      ./hardware-configuration.nix
      ./env.nix
      ./display.nix
    ];

  # Grub 2 bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.nixos.device = "/dev/disk/by-uuid/c0c54529-0aae-45d4-833d-b2a3c8a1dfb4";

  networking.hostName = "rusty-nix";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  # Auto cleanup garbage
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 30d";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  services.xserver.libinput.enable = true;
  services.printing.enable = true;

  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [{
    users = [ "wouter" ];
    keepEnv = true;
    persist = true;
  }];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.wouter = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
    packages = with pkgs; [
      alacritty
      firefox
      flameshot
      rofi
      syncthing
      picom
      keepassxc
      neovim
      bspwm
      sxhkd
      polybar
      picom
      dunst
      git
      docker
      libinput
    ];
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.wouter = import ../home-manager/home.nix;
  };
  services.openssh.enable = true;

  system.copySystemConfiguration = true;
  system.stateVersion = "23.05";
}
