{
    flake.modules.nixos."dev/android" = { pkgs, ... }: {
        # The SDK, NDK and Android Studio live per-project in the android
        # template; adb stays system level for device access (udev/uaccess
        # rules are handled by systemd).
        environment.systemPackages = with pkgs; [
            android-tools
        ];
    };
}
