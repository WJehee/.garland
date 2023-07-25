{ config, pkgs, ... }:
{
  home.username = "wouter";
  home.homeDirectory = "/home/wouter";
  home.stateVersion = "23.05";
  home.packages = [];

  services.picom.enable = true;
  services.polybar.enable = true;
  services.polybar.script = "polybar laptop-primary &";
  xsession.windowManager.bspwm = {
    enable = true;
    monitors = {
      eDP-1 = ["1" "2" "3" "4" "5" "6" "7" "8" "9" "10"];
    };
    startupPrograms = [
      "xrdb $XDG_CONFIG_HOME/X11/Xresources"
      "systemctl --user restart polybar"
    ];
  };

  programs.alacritty = {
    enable = true;
    settings.window.opacity = 0.85;
  };
  programs.git = {
    enable = true;
    userName = "Wouter Jehee";
    userEmail = "wouterjehee@tutanota.com";
    ignores = [
      ".env"
      "_pycache_/"
    ];
  };
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
  };
}
