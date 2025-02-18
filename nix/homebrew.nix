{ ... }:
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "remote.remote";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    casks = [
      "aerospace"
      "spotify"
      "brave-browser"
      # "bartender"
    ];
    taps = [
      "nikitabobko/tap"
    ];
    onActivation.cleanup = "zap";
  };
}
