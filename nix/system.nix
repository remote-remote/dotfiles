{ pkgs, ... }:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs;
    [ 
      zsh
      gawk
      fzf
      ripgrep
    ];

  system.defaults = {
    loginwindow.LoginwindowText = "remote.remote";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticWindowAnimationsEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSNavPanelExpandedStateForSaveMode = true;
      PMPrintingExpandedStateForPrint = true;
    };
    LaunchServices = {
      LSQuarantine = false;
    };
    trackpad = {
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
      Clicking = true;
    };
    finder = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      CreateDesktop = false;
      # FXPreferredViewStyle = "clmv";
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
    };
    dock = {
      autohide = true;
      expose-animation-duration = 0.15;
      show-recents = false;
      showhidden = true;
      mru-spaces = false;
      tilesize = 50;
    };
  };

}
