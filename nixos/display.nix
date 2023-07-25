{ config, pkgs,... }:
{
  services.picom.enable = true;
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e,caps:escape";
    videoDrivers = ["modesetting"];

    windowManager.bspwm.enable = true;
    displayManager = {
      defaultSession = "none+bspwm";
      lightdm.enable = true;
      autoLogin.enable = true;
      autoLogin.user = "wouter";
    };
  };
}
