{ config, pkgs, username, remote, ... }:
{
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";

    packages = with pkgs; [
      gawk
      fzf
      jq
      ripgrep
      nerd-fonts.inconsolata
      neovim
      zoxide
      direnv
      devenv
      stow
      awscli2
      docker
      docker-credential-helpers
      colima
      lua
      nodejs
      typescript-language-server
      vue-language-server
    ];

    file = {
      ".config/kitty/kitty-themes".source = ../../kitty/kitty-themes;
      ".config/kitty/kitty.conf" = {
        source = ../../kitty/kitty.conf;
        onChange = "kill -SIGUSR1 $KITTY_PID";
      };
      ".config/kitty/background.webp".source = ../../kitty/background.webp;
      ".config/nvim".source = ../../nvim;
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
