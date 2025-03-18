{ nix-homebrew, ... }: {
  hostname = "midnight-remote";
  system = "aarch64-darwin";

  homebrew = {};

  multiplexer = "kitty";
}
