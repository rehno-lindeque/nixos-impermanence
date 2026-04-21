{
  config,
  lib,
  ...
}: let
  cfg = config.programs.ssh;
in {
  options = with lib; {
    programs.ssh.persistence = mkOption {
      type = types.attrsOf types.raw;
      default = {
        secret.files = [
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            method = "reconcile";
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key.pub";
            method = "reconcile";
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key";
            method = "reconcile";
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key.pub";
            method = "reconcile";
          }
        ];
      };
      description = ''
        Persist SSH host keys.
      '';
    };
  };

  config = let
    persistence = builtins.intersectAttrs config.environment.automaticPersistence cfg.persistence;
  in
    lib.mkIf (persistence != {}) {
      environment.persistence =
        lib.mkMerge
        (lib.mapAttrsToList
          (k: v: {${config.environment.automaticPersistence.${k}.path} = v;})
          persistence);
    };
}
