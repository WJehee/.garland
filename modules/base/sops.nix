{ inputs, ... }: {
    flake.modules.nixos.base = { config, pkgs, ... }: {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        sops = {
            defaultSopsFile = ../../secrets/${config.networking.hostName}.yaml;
            age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

            # TODO: remove this override once https://github.com/Mic92/sops-nix/issues/983
            # is fixed (PR https://github.com/Mic92/sops-nix/pull/984) and the sops-nix
            # input is updated past it. sops-install-secrets is built with the versioned
            # `buildGo125Module`, which nixpkgs turned into a throw when Go 1.25 went
            # end-of-life, so the default `sops.package` no longer evaluates. The module
            # builds the package against our nixpkgs via `import sops-nix { inherit pkgs; }`,
            # so handing it a pkgs where the removed builder aliases the unversioned one is
            # enough; this keeps upstream's vendorHash and build recipe instead of copying them.
            package = (import inputs.sops-nix {
                pkgs = pkgs.extend (_: prev: { buildGo125Module = prev.buildGoModule; });
            }).sops-install-secrets;
        };
    };
}
