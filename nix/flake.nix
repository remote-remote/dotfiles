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

    # Homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  # outputs is a function that takes inputs, plus this `self` thing
  # not sure what `self` is...
  outputs = inputs@{ self, darwin, nixpkgs, nix-homebrew, home-manager, ... }:
  # let is naming some stuff for use in the `in` block
  let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
    configuration = { pkgs, ... }: {
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      security.pam.enableSudoTouchIdAuth = true;
    };
  in
  {

    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#midnight-remote
    darwinConfigurations."midnight-remote" = darwin.lib.darwinSystem {
      modules = [ 
        configuration 
        ./system.nix
        ./homebrew.nix
        nix-homebrew.darwinModules.nix-homebrew
      ];
    };
  };
}
