{
  description = "Example nix-darwin system flake";

  # dependencies of the flake?
  inputs = {
    # this is the same as:
    # nixpkgs = {
    #   url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # }
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  # outputs is a function that takes inputs, plus this `self` thing
  # not sure what `self` is...
  outputs = inputs @ { self, darwin, nixpkgs, home-manager, nix-homebrew, ... }:
  # let is naming some stuff for use in the `in` block
  let
    inherit (self) outputs;

    mkHomeConfig = username: config: home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = config.system;};
      extraSpecialArgs = {
        inherit username;
        remote = config;
      };
      modules = [
        ./home-manager/home.nix
        ./home-manager/zsh.nix
        ./home-manager/multiplexer.nix
        ./home-manager/postgres.nix
      ];
    };

    mkDarwinConfig = username: config: darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs outputs username;
      };
      modules = config.darwinModules;
    };

    work = (import ./work.nix) inputs;
    personal = (import ./personal.nix) inputs;
  in {
    darwinConfigurations."work-remote" = mkDarwinConfig "work.remote" work;
    darwinConfigurations."midnight-remote" = mkDarwinConfig "remote.remote" personal;
    homeConfigurations."work.remote" = mkHomeConfig "work.remote" work;
    homeConfigurations."remote.remote" = mkHomeConfig "remote.remote" personal;
  };
}
