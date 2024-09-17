{ pkgs, ... }: {
    programs.zsh = {
        enable = true;
        setOptions = [
            "AUTO_CD"
            "COMPLETE_ALIASES"
        ];
    };
}
