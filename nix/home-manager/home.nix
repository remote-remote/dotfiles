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
      nerd-fonts.fira-code
      nerd-fonts.inconsolata
      nerd-fonts.iosevka
      nerd-fonts.jetbrains-mono
      nerd-fonts.monoid
      nerd-fonts.proggy-clean-tt
      nerd-fonts.zed-mono
      nmap
      postgresql
      redis
      ripgrep
      sc-im
      stow
      tree-sitter
      typescript-language-server
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
    };

    sessionVariables = {
      EDITOR = "nvim";
      GOPATH = "$HOME/go";
      PATH = "$HOME/go/bin:$HOME/bin:$HOME/.local/bin:$PATH";
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

    go.enable = true;
  };
}
