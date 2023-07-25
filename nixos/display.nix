{ config, pkgs,... }:
{
  services.picom.enable = true;
  programs.hyprland.enable = true;
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e,caps:escape";
    videoDrivers = ["modesetting"];

    windowManager.bspwm.enable = true;
    displayManager = {
      defaultSession = "hyprland";
      lightdm.enable = true;
      autoLogin.enable = true;
      autoLogin.user = "wouter";
    };
  };
}
