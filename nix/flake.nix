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

    mkHomeConfig = remote: home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = remote.system;};
      extraSpecialArgs = {
        # I can make this dynamic somehow, but for now... the kitty thing works pretty good.
        inherit remote;
      };
      modules = [
        ./home-manager/home.nix
        ./home-manager/zsh.nix
        ./home-manager/multiplexer.nix
        ./home-manager/postgres.nix
      ];
    };

    mkDarwinConfig = remote: darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs outputs;
        username = remote.username;
      };
      modules = [
        ./system.nix
      ] ++ (if remote.brew.nix then [
        nix-homebrew.darwinModules.nix-homebrew
        ./homebrew.nix
      ] else []);
    };

    remote = import ./config.nix;
  in {
    darwinConfigurations.${remote.hostname} = mkDarwinConfig remote;
    homeConfigurations.${remote.username} = mkHomeConfig remote;
  };
}
