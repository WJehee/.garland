# sops-nix, decrypting secrets/<hostname>.yaml with an age key derived from
# the SSH host key. Enrolling a host: docs/host-enrollment.adoc.
#
# Convention: every module that declares `sops.secrets` starts with a
# "Secrets" comment block listing its keys and what value each one takes.
# The assertions below depend on that convention. A secret that is declared
# but absent from the host's secrets file fails the evaluation with a message
# naming the file that declared it, so the reader lands on that block.
# Without them the same mistake only surfaces later, as a sops-nix manifest
# build error that names the key but not where it is documented.
{ inputs, ... }: {
    flake.modules.nixos.base = { config, options, lib, ... }: let
        # The module system records definition locations as
        # "/nix/store/<hash>-source/modules/x.nix, via option flake.modules...".
        # Only the repository-relative path is useful in a message.
        repoPath = location: let
            file = lib.head (lib.splitString ", via option" location);
            relative = builtins.match "/nix/store/[^/]+/(.*)" file;
        in if relative == null then file else lib.head relative;

        declaredIn = name: lib.unique (map (definition: repoPath definition.file)
            (lib.filter (definition: definition.value ? ${name})
                options.sops.secrets.definitionsWithLocations));

        # The check is textual because Nix has no YAML parser: sops leaves
        # key names in plaintext and only encrypts the values, so a key is
        # present when some line starts with "<key>:". A name with slashes
        # addresses a nested map ("blotter/FOO" is FOO under blotter), and
        # each segment is looked up at any indentation. That can wrongly
        # report a nested key as present, which is harmless: sops-nix's own
        # validation still runs when the system is built.
        hasKey = file: key: let
            lines = map lib.trim (lib.splitString "\n" (builtins.readFile file));
        in builtins.pathExists file
            && lib.all (segment: lib.any (lib.hasPrefix "${segment}:") lines)
                (lib.splitString "/" key);

        secretAssertion = name: secret: let
            file = "secrets/${baseNameOf secret.sopsFile}";
        in {
            assertion = hasKey secret.sopsFile secret.key;
            message = ''
                The sops secret `${secret.key}` is missing from ${file}.
                It is declared in ${lib.concatStringsSep " and " (declaredIn name)}; the "Secrets" comment at the top of that file says what value belongs there.
                Add it with `just secrets ${lib.removeSuffix ".yaml" (baseNameOf secret.sopsFile)}`.
            '';
        };

        # Other formats (binary, dotenv, ...) and an empty key (the whole
        # file) do not have the "<key>:" line structure the check relies on.
        checkable = lib.filterAttrs
            (_: secret: secret.format == "yaml" && secret.key != "")
            config.sops.secrets;
    in {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        sops = {
            defaultSopsFile = ../../secrets/${config.networking.hostName}.yaml;
            age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        };
        assertions = lib.mapAttrsToList secretAssertion checkable;
    };
}
