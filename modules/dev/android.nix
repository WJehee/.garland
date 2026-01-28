{ pkgs, ...}: {
    users.users.wouter.extraGroups = ["adbusers"];
    nixpkgs.config.android_sdk.accept_license = true;
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
