{
  description = "Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    system = "aarch64-darwin";
    username = builtins.getEnv "USER";
  in {
    homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { inherit system; };
      extraSpecialArgs = {
        inherit username;
        remote = {
          multiplexer = "tmux";
        };
      };
      modules = [
        ./home-manager/home.nix
        ./home-manager/zsh.nix
        ./home-manager/multiplexer.nix
      ];
    };
  };
}
