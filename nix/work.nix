{ nix-homebrew, ... }: {
  hostname = "work-remote";
  system = "aarch64-darwin";

  darwinModules = [
    ./system.nix
  ];

  brew = {
    nix = false;
    nvm = true;
    rbenv = true;
  };

  postgres = true;
  multiplexer = "kitty";
}
