{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        exiftool        # EXIF data
        sherlock        # username search
    ];
}
