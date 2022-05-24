{
  config,
  lib,
  ...
}: let
  cfg = config.networking.networkmanager;
in {
  options = with lib; {
    networking.networkmanager.persistence = mkOption {
      type = types.attrsOf types.raw;
      default = {
        transient.directories = ["/var/lib/NetworkManager"];
        secret.directories = ["/etc/NetworkManager/system-connections"];
      };
      description = ''
        Persist network manager settings, keys, and connections.
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
