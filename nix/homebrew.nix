{ user, ... }:
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "${user}";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    casks = [
      "aerospace"
      "spotify"
      "brave-browser"
      "kitty"
      # work crap
      # "nvm"
      # "rbenv"
      "slack"
      "zoom"
    ];
    taps = [
      "nikitabobko/tap"
    ];
    onActivation.cleanup = "zap";
  };
}
