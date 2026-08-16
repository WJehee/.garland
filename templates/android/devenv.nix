{ pkgs, ... }:
{
    android = {
        enable = true;
        android-studio.enable = true;
    };

    languages.java.enable = true;

    packages = with pkgs; [
        apktool
    ];
}
