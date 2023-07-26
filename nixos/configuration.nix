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
  boot.initrd.luks.devices.nixos.device = "/dev/disk/by-uuid/38fbea60-655c-4784-92c4-a0c0dac7d6d1";

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
  services.printing.enable = true;

  security.doas.enable = true;
  security.sudo.enable = true;
  security.doas.extraRules = [{
    users = [ "wouter" ];
    keepEnv = true;
    persist = true;
  }];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.wouter = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    packages = with pkgs; [
      alacritty
      firefox
      wofi
      grim
      syncthing
      keepassxc
      neovim
      bspwm
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

  system.stateVersion = "23.05";
}
