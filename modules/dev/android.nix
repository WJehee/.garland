{pkgs, ...}: {
    programs.adb.enable = true;
    users.users.wouter.extraGroups = ["adbusers"];
    environment.systemPackages = with pkgs; [
        (android-studio.withSdk (androidenv.composeAndroidPackages {
            includeNDK = true;
        }).androidsdk)
        android-studio-tools
        apktool
        apksigner
        zulu
    ];
}
