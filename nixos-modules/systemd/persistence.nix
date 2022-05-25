{
  config,
  lib,
  ...
}: let
  cfg = config.systemd;
in {
  options = with lib; {
    systemd.persistence = mkOption {
      type = types.attrsOf types.raw;
      default = {
        normal.directories = [
          "/var/lib/systemd/coredump"
        ];
      };
      description = ''
        Persists logs created by `systemd-coredump`.
      '';
    };
  };

  config = let
    persistence = builtins.intersectAttrs config.environment.automaticPersistence cfg.persistence;
  in
    lib.mkIf (cfg.coredump.enable && persistence != {}) {
      environment.persistence =
        lib.mkMerge
        (lib.mapAttrsToList
          (k: v: {${config.environment.automaticPersistence.${k}.path} = v;})
          persistence);
    };
}
