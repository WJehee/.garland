{ pkgs, ... }: let
    version = "02.07.01.57";
    # Official upstream AppImage, avoids the heavy (OOM-prone) source build.
    src = pkgs.fetchurl {
        url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/BambuStudio_ubuntu-24.04-v${version}-20260601192128.AppImage";
        sha256 = "0lzbz3awnzd2dhkx4a14b5h55qs4jp8x9qksrmsqf8qs7y2m7c45";
    };
    bambu-studio = pkgs.appimageTools.wrapType2 {
        pname = "bambu-studio";
        inherit version src;
        # Embedded login/webview needs webkitgtk at runtime.
        extraPkgs = pkgs: with pkgs; [ webkitgtk_4_1 ];
    };
in {
    environment.systemPackages = [ bambu-studio ];
}
