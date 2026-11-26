{ pkgs, ... }:
{
    languages.elixir = {
        enable = true;
        # The host Erlang/OTP major version must match the one compiled into the
        # Nerves system for the target: `mix firmware` refuses to build on a
        # mismatch. nerves_system_rpi3 2.2.x ships OTP 29. When bumping the
        # system, check its CHANGELOG.md for the OTP version and pick the
        # beam<NN>Packages set (and an Elixir that supports it) to match.
        package = pkgs.beam29Packages.elixir_1_20;
    };

    # The tag of the board to build firmware for, see
    # https://nerves.hexdocs.pm/supported-targets.html. Tests run on the host
    # instead, the justfile overrides this to `host` for them.
    env.MIX_TARGET = "rpi3";

    packages = with pkgs; [
        # Assembles and burns the .fw firmware archive.
        fwup
        # mksquashfs builds the root filesystem image.
        squashfsTools
        # The nerves dependency and several nerves_pack dependencies compile
        # small C ports, partly for the host (needs gcc), partly with the
        # cross toolchain Nerves downloads into ~/.nerves. That toolchain is a
        # generic prebuilt linux binary, so on NixOS it relies on nix-ld
        # (enabled on all workstations).
        gnumake
        gcc
        pkg-config
        # nerves_uevent links against it when compiled for the host (tests).
        libmnl
    ];
}
