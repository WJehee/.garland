{pkgs, ...}: {
    users.users.wouter.extraGroups = ["adbusers"];
    environment.systemPackages = with pkgs; [
        android-tools
        apktool
        (android-studio.withSdk (androidenv.composeAndroidPackages {
            includeNDK = true;
        }).androidsdk)
        android-studio-tools
        apksigner
        zulu
    ];
}
