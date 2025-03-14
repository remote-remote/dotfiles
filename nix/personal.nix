{ nix-homebrew, ... }: {
  hostname = "midnight-remote";
  system = "aarch64-darwin";

  darwinModules = [
    ./system.nix
    nix-homebrew.darwinModules.nix-homebrew
    ./homebrew.nix
  ];

  brew = {
    nix = true;
    nvm = false;
    rbenv = false;
  };

  postgres = false;
  multiplexer = "kitty";
}
