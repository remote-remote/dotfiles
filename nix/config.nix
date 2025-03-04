{
  username = "remote.remote";
  hostname = "midnight-remote";
  system = "aarch64-darwin";

  brew = {
    nix = true;
    nvm = false;
    rbenv = false;
  };
  postgres = true;
  multiplexer = "kitty";
}
