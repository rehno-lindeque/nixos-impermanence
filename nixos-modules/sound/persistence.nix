{
  config,
  lib,
  ...
}: let
  cfg = config.sound;
in {
  options = with lib; {
    sound.persistence = mkOption {
      type = types.attrsOf types.raw;
      default = {
        transient.files = ["/var/lib/alsa/asound.state"];
      };
      description = ''
        Persist audio volume settings, managed via a combination of alsactl and systemd.
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
