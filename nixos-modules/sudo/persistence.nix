{
  config,
  lib,
  ...
}: let
  cfg = config.security.sudo;
in {
  options = with lib; {
    security.sudo.persistence = mkOption {
      type = types.attrsOf types.raw;
      default = {
        normal.directories = [
          # Avoid getting repeatedly lectured by sudo
          "/etc/db/sudo/lectured"
        ];
      };
      description = ''
        Persists sudo's lectured users.

        An alternative would be to set `security.sudo.extraConfig = "Defaults lecture=never"`.
      '';
    };
  };

  config = let
    persistence = builtins.intersectAttrs config.environment.automaticPersistence cfg.persistence;
  in
    # In future we may want to check if sudo has lecture=never set.
    # However at the moment this can only be set via security.sudo.extraConfig.
    # If nixos adds a specific option for this we can alter it.
    lib.mkIf (cfg.enable && persistence != {}) {
      environment.persistence =
        lib.mkMerge
        (lib.mapAttrsToList
          (k: v: {${config.environment.automaticPersistence.${k}.path} = v;})
          persistence);
    };
}
