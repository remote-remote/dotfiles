{ nix-homebrew, ... }: {
  hostname = "work-remote";
  system = "aarch64-darwin";

  homebrew = {
    homebrew.casks = [
      "visual-studio-code"
    ];
  };

  multiplexer = "kitty";
}
