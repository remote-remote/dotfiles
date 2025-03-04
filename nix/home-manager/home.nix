{ config, pkgs, remote, ... }:
{
  home = {
    username = "${remote.username}";
    homeDirectory = "/Users/${remote.username}";
    stateVersion = "24.11";

    packages = with pkgs; [
      gawk
      fzf
      ripgrep
      zoxide
      neovim
      direnv
      # Maybe add this later
      # rbenv
      # nvm
    ];

    file = {
      ".config/kitty/kitty-themes".source = ../../kitty/kitty-themes;
      ".config/kitty/kitty.conf" = {
        source = ../../kitty/kitty.conf;
        onChange = "kill -SIGUSR1 $KITTY_PID";
      };
    };

    sessionVariables = {
      EDITOR = "nvim";
      HOMEBREW_PREFIX = "/opt/homebrew";
      PATH = "$HOME/bin:$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Applications/SnowSQL.app/Contents/MacOS:$HOME/Library/Application Support/JetBrains/Toolbox/scripts:$PATH";
      MANPATH = "/opt/homebrew/share/man:$MANPATH";
      INFOPATH = "/opt/homebrew/share/info:$INFOPATH";
      NVM_DIR = "$HOME/.nvm";
    };
  };

  programs = {
    home-manager.enable = true;

    zoxide = {
      enable = true;
    };
  };
}
