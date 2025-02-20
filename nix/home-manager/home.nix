{ config, pkgs, multiplexer, ... }:
{
  home = {
    username = "remote.remote";
    homeDirectory = "/Users/remote.remote";
    stateVersion = "24.11"; # Please read the comment before changing.

    # maybe I should not have kitty here, but in the system config?
    # but this is dependent on it...
    packages = with pkgs; [
      zsh
      gawk
      fzf
      ripgrep
    ];

    file = {
      ".config/kitty/kitty-themes".source = ../../kitty/kitty-themes;
    };

    sessionVariables = {
    # EDITOR = "emacs";
    };
  };


  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
