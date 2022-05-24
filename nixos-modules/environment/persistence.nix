{
  config,
  lib,
  ...
}: let
  cfg = config.environment;
in {
  options = with lib; {
    environment = {
      automaticPersistence = mkOption {
        type = types.attrsOf (lib.types.submodule {
          options.path = lib.mkOption {
            type = types.str;
          };
        });
        # type = types.attrsOf types.raw;
        default = {};
        example = {
          transient = null;
          normal.path = "/persistent";
          important.path = "/persistent";
          secret.path = "/secret";
        };
        apply = x:
          (
            # Issue a warning when multiple persistence targets are specified
            if builtins.length (builtins.attrNames x) > 2
            then lib.warn "Setting multiple persistence targets is experimental, and not recommended at this time."
            else lib.id
          )
          # Copy lower priority settings to higher priority levels if they've been ommited.
          # Also filter out null settings.
          (lib.filterAttrs
            (k: v: v != null)
            (lib.fix (final: {
              transient = x.transient or null;
              normal = x.normal or final.transient or null;
              important = x.important or final.normal or null;
              secret = x.secret or final.normal or null;
            })));

        description = ''
          Persistent storage paths where automatically persisted files are kept by default.

          nixos-impermanence provides four categories for automatic persistence.
          Listed in lowest to highest priority order, these are:

          * `transient`: includes all files that are associated with holding state, including caches and other transient state.
          * `normal`: includes files that are associated with non-essential settings and data which can presumably be manually recovered, albeit with a fair amount of tedium.
          * `important`: only files that are associated with important state that cannot be easily recovered or regenerated if lost, such as databases, etc.
          * `secret`: only files that are both important and confidential will be persisted.

          Note that setting paths against multiple of these persistence levels to split up your persistent storage is an experimental goal, not recommended at this time.
        '';
      };

      machineId.persistence = mkOption {
        type = types.attrsOf types.raw;
        default = {
          normal.files = ["/etc/machine-id"];
        };
        description =
          # See http://jdebp.uk./Softwares/nosh/guide/commands/machine-id.xml
          ''
            Retain a unique machine id in /etc/machine-id.
            The machine-id should be considered confidential (for privacy, not security).
            Note that Google Chrome is known to transmit a hashed version of this id in order to lock user profiles to known machines.
            It is also by various system tools such as journalctl, systemd-networkd, and
          '';
      };
    };
  };

  config = let
    persistence = builtins.intersectAttrs config.environment.automaticPersistence cfg.machineId.persistence;
  in
    lib.mkIf (persistence != {}) {
      environment.persistence =
        lib.mkMerge
        (lib.mapAttrsToList
          (k: v: {${config.environment.automaticPersistence.${k}.path} = v;})
          persistence);
    };
}
