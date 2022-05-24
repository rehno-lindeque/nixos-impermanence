{
  config,
  lib,
  ...
}: let
  cfg = config.hardware.bluetooth;
in {
  options = with lib; {
    hardware.bluetooth.persistence = mkOption {
      type = types.attrsOf types.raw;
      default = {
        normal.directories = ["/var/lib/bluetooth"];
      };
      description = ''
        Persist bluetooth settings and caches (all adapters).
        See https://github.com/pauloborges/bluez/blob/master/doc/settings-storage.txt for details.
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
