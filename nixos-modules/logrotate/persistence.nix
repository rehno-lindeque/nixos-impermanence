{
  config,
  lib,
  ...
}: let
  cfg = config.services.logrotate;
in {
  options = with lib; {
    services.logrotate.persistence = mkOption {
      type = types.attrsOf types.raw;
      default = {
        normal.files = ["/var/lib/logrotate.status"];
      };
      # TODO: explain what effect persisting this state file has
      description = ''
        Persist logrotate state file.
      '';
    };
  };

  config = let
    persistence = builtins.intersectAttrs config.environment.automaticPersistence cfg.persistence;
  in
    lib.mkIf (cfg.enable && persistence != {}) {
      environment.persistence =
        lib.mkMerge
        (lib.mapAttrsToList
          (k: v: {${config.environment.automaticPersistence.${k}.path} = v;})
          persistence);
    };
}
