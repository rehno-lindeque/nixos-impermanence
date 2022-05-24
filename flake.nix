{
  description = "Impermanence options for NixOS modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs"; # /nixos-22.05
  };
  outputs = {
    self,
    nixpkgs,
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
}
