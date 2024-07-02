{   
    stdenv,
    fetchgit,
    meson,
    ninja,
    pkg-config,
    cmake,
    libcpr,
    zmqpp,
    libbsd,
    can-utils,
    libyaml,
}:

stdenv.mkDerivation {
    name = "csh";
    src = fetchgit {
        url = "https://github.com/spaceinventor/csh/";
        rev = "67bd0ba9d42fed46930e6c084fbc55de0c4e0fc2";
        sha256 = "sha256-batqwMI+3zOR1LhBXviv1bxuqM7LevoFyZ0+Zd31aw0=";
    };
    nativeBuildInputs = [
        meson
        ninja
        pkg-config
        cmake
        libcpr
        zmqpp
        libbsd
        can-utils
        libyaml
    ];
    configurePhase = ''
        meson setup . builddir -Dprefix=$out
        meson configure --optimization 1 builddir
        cd builddir
    '';
}
