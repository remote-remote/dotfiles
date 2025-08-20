{ config, pkgs, username, remote, nixpkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";

    packages = with pkgs; [
      awscli2
      colima
      devenv
      direnv
      docker
      docker-credential-helpers
      fswatch
      fzf
      gawk
      jq
      lazygit
      lua
      lua-language-server
      neovim
      nerd-fonts.inconsolata
      nodejs
      ripgrep
      stow
      typescript-language-server
      # vue-language-server
      yazi
      zoxide
    ];

    file = {
      ".config/kitty/kitty-themes".source = ../../kitty/kitty-themes;
      ".config/kitty/kitty.conf" = {
        source = ../../kitty/kitty.conf;
        onChange = "kill -SIGUSR1 $KITTY_PID";
      };
      ".config/kitty/background.webp".source = ../../kitty/background.webp;
      ".docker/config.json".source = ../../docker/config.json;
    };

    sessionVariables = {
      EDITOR = "nvim";
      PATH = "$HOME/bin:$HOME/.local/bin:$PATH";
    };
  };

  programs = {
    home-manager.enable = true;

    zoxide = {
      enable = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
