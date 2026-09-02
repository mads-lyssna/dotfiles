{
  description = "Cross-platform home-manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    worktrunk = {
      url = "github:max-sixty/worktrunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agents = {
      url = "github:mads-lyssna/agents";
      flake = false;
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      hunk,
      worktrunk,
      agents,
      catppuccin,
      ...
    }:
    let
      mkHome =
        { system, homeDirectory }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [
            ./home.nix
            catppuccin.homeModules.catppuccin
            hunk.homeManagerModules.default
            worktrunk.homeModules.default
          ];
          extraSpecialArgs = {
            inherit homeDirectory agents;
          };
        };
    in
    {
      apps.aarch64-darwin.home-manager = {
        type = "app";
        program = "${home-manager.packages.aarch64-darwin.default}/bin/home-manager";
      };

      homeConfigurations = {
        # Mac
        "madeleine.ostoja" = mkHome {
          system = "aarch64-darwin";
          homeDirectory = "/Users/madeleine.ostoja";
        };

        # Linux devcontainer (lyssna user)
        lyssna = mkHome {
          system = "aarch64-linux";
          homeDirectory = "/home/lyssna";
        };
      };
    };
}
