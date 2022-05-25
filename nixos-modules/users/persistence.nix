{
  config,
  lib,
  ...
}: let
  cfg = config.users;
in {
  options = with lib; {
    users.persistence = mkOption {
      type = types.attrsOf types.raw;
      default = {
        secret.files = [
          # See the comments starting from https://github.com/NixOS/nixpkgs/issues/3192#issuecomment-753521052
          # for more color on how /etc/passwd, /etc/shadow is updated by passwd
          "/etc/passwd"
          "/etc/shadow"
        ];
      };
      description = ''
        Persist user credentials if `users.mutableUsers` is enabled.

        WARNING: to change a password with `passwd` you *must* use the `--root` argument.
        For example: `passwd --root /persistent/etc myusername`
      '';
    };
  };

  config = let
    persistence = builtins.intersectAttrs config.environment.automaticPersistence cfg.persistence;
  in
    lib.mkIf (cfg.mutableUsers && persistence != {}) {
      environment.persistence =
        lib.mkMerge
        (lib.mapAttrsToList
          (k: v: {${config.environment.automaticPersistence.${k}.path} = v;})
          persistence);
    };
}
