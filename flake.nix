{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs_unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs_unstable, ... }@inputs: {

    nixosConfigurations = {
          default = nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";

            # The `specialArgs` parameter passes the
            # non-default nixpkgs instances to other nix modules
            specialArgs = {
              # To use packages from nixpkgs-stable,
              # we configure some parameters for it first
              pkgs-unstable = import nixpkgs_unstable {
                # Refer to the `system` parameter from
                # the outer scope recursively
                inherit system;
                # To use Chrome, we need to allow the
                # installation of non-free software.
                config.allowUnfree = true;
              };

              inherit inputs;
            };

            modules = [
              ./hosts/default/configuration.nix
            ];
          };
        };


    #nixosConfigurations.default = nixpkgs.lib.nixosSystem {
    #  #system = "x86_64-linux";

    #  specialArgs = {
    #    #pkgs-unstable = import nixpkgs_unstable {
    #    #  #inherit system;
    #    #  config.allowUnfree = true;
    #    #};

    #    #inherit inputs;

    #  };

    #  modules = [
    #    ./hosts/default/configuration.nix
    #  ];
    #};

    nixosConfigurations.lxc = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [
            ./hosts/lxc/configuration.nix
          ];
        };
  };
}
