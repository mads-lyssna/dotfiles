{
  description = "Apple Silicon Home Manager configuration";

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
    {
      nixpkgs,
      home-manager,
      hunk,
      agents,
      catppuccin,
      ...
    }:
    {
      apps.aarch64-darwin.home-manager = {
        type = "app";
        program = "${home-manager.packages.aarch64-darwin.default}/bin/home-manager";
      };

      homeConfigurations."madeleine.ostoja" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        modules = [
          ./home.nix
          catppuccin.homeModules.catppuccin
          hunk.homeManagerModules.default
        ];
        extraSpecialArgs = {
          homeDirectory = "/Users/madeleine.ostoja";
          inherit agents;
        };
      };
    };
}
