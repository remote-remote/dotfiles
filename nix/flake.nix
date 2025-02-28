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
    # nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  # outputs is a function that takes inputs, plus this `self` thing
  # not sure what `self` is...
  outputs = inputs @ { self, darwin, nixpkgs, home-manager, ... }:
  # let is naming some stuff for use in the `in` block
  let
    inherit (self) outputs;

    mkHomeConfig = username: system: home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {inherit system;};
      extraSpecialArgs = {
        # I can make this dynamic somehow, but for now... the kitty thing works pretty good.
        multiplexer = "kitty";
        username = username;
      };
      modules = [
        ./home-manager/home.nix
        ./home-manager/zsh.nix
        ./home-manager/multiplexer.nix
        ./home-manager/postgres.nix
      ];
    };

    mkDarwinConfig = username: darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs outputs username;
      };
      modules = [
        ./system.nix
        # ./homebrew.nix
        # nix-homebrew.darwinModules.nix-homebrew
      ];
    };
  in {
    darwinConfigurations."work-remote" = mkDarwinConfig "remote.worker";
    darwinConfigurations."midnight-remote" = mkDarwinConfig "remote.remote";
    homeConfigurations."remote.remote" = mkHomeConfig "remote.remote" "aarch64-darwin";
  };
}
