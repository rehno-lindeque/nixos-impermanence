{
  description = "Impermanence options for NixOS modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Input is used for checks
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs = {
    self,
    nixpkgs,
    impermanence,
  }: let
    lib = nixpkgs.lib;
    defaultSystems = [
      "aarch64-linux"
      "aarch64-darwin"
      "i686-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  in {
    formatter = lib.genAttrs defaultSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    nixosModules = rec {
      bluetooth = import ./nixos-modules/bluetooth/persistence.nix;
      environment = import ./nixos-modules/environment/persistence.nix;
      networkmanager = import ./nixos-modules/networkmanager/persistence.nix;
      ssh = import ./nixos-modules/ssh/persistence.nix;
      sudo = import ./nixos-modules/sudo/persistence.nix;
      systemd = import ./nixos-modules/systemd/persistence.nix;
      tailscale = import ./nixos-modules/tailscale/persistence.nix;
      default = {
        imports = [
          bluetooth
          environment
          networkmanager
          ssh
          sudo
          systemd
          tailscale
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
