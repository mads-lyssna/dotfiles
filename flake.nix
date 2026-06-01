{
  description = "Cross-platform home-manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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
    catppuccin-godot = {
      url = "github:catppuccin/godot";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      agents,
      catppuccin,
      catppuccin-godot,
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
          ];
          extraSpecialArgs = {
            inherit
              homeDirectory
              agents
              catppuccin-godot
              ;
          };
        };
    in
    {
      homeConfigurations = {
        # Mac
        "madeleine.ostoja" = mkHome {
          system = "aarch64-darwin";
          homeDirectory = "/Users/madeleine.ostoja";
        };

        # Linux devcontainer (vscode user)
        vscode = mkHome {
          system = "aarch64-linux";
          homeDirectory = "/home/vscode";
        };
      };
    };
}
