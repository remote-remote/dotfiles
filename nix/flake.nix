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
  outputs = inputs@{ self, darwin, nixpkgs, home-manager, ... }:
  # let is naming some stuff for use in the `in` block
  let
    inherit home-manager;
    # Dynamic username, empty string fallback (then "jasonamador")
    username = let u = builtins.getEnv "USER"; 
    in if u == "" then "user" else u;

    # Dynamic hostname with fallbacks
    hostname = let
      envHost = builtins.getEnv "HOST";
    in
      if envHost != "" then envHost
      else "Jasons-MacBook-Pro-2";

    system = "aarch64-darwin";

    pkgs = nixpkgs.legacyPackages.${system};

    mkHomeConfig = username: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
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
    
    configuration = { pkgs, ... }: {
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;
      # Preserve Homebrew
      environment.pathsToLink = [ "/opt/homebrew/bin" ];  # Keep Homebrew in PATH
      environment.etc."homebrew/Brewfile".enable = false;  # Don’t manage Brewfile

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      security.pam.enableSudoTouchIdAuth = true;
    };
  in {

    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#midnight-remote
    darwinConfigurations."${hostname}" = darwin.lib.darwinSystem {
      specialArgs = {
        inherit username;
      };
      modules = [
        configuration
        ./system.nix
        # ./homebrew.nix
        # nix-homebrew.darwinModules.nix-homebrew
      ];
    };
    homeConfigurations."${username}" = mkHomeConfig "${username}";
  };
}
