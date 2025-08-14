{ username, ... }:
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "${username}";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    casks = [
      "aerospace"
      "spotify"
      "brave-browser"
      "kitty"
      "slack"
      "zoom"
      "bruno"
      # I needed this for Evision (OpenCV) to work
      "tesseract"
    ];
    taps = [
      "nikitabobko/tap"
    ];
    onActivation.cleanup = "zap";
  };
}
