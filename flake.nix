{
  description = "Impermanence options for NixOS modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs"; # /nixos-22.05

    # Input is used for checks
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs = {
    self,
    nixpkgs,
    impermanence,
  }: let
    lib = nixpkgs.lib;
  in {
    nixosModules = rec {
      environment = import ./nixos-modules/environment/persistence.nix;
      default = {
        imports = [
          environment
        ];
      };
    };

    checks.x86_64-linux.example =
      (lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          impermanence.nixosModules.impermanence
          self.nixosModules.default
          {
            environment.automaticPersistence = {
              normal.path = "/persistence";
            };
            boot.loader.systemd-boot.enable = true;
            fileSystems."/".device = "none";
          }
        ];
      })
      .config
      .system
      .build
      .toplevel;
  };
}
