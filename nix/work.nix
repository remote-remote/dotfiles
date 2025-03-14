{
  hostname = "work-remote";
  system = "aarch64-darwin";

  brew = {
    nix = false;
    nvm = true;
    rbenv = true;
  };
  postgres = true;
  multiplexer = "kitty";
}
