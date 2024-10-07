{pkgs, ...}: {
    programs.adb.enable = true;
    users.users.wouter.extraGroups = ["adbusers"];
    environment.systemPackages = with pkgs; [
        android-studio
        android-studio-tools
        apktool
    ];
}
