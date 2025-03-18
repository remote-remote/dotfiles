{ config, pkgs, username, remote, ... }:
{
  home = {
    inherit username;
    packages = with pkgs; [
      fzf
      ripgrep
      neovim
    ];

    file = {
      ".config/nvim".source = ../../nvim;
    };

    sessionVariables = {
      EDITOR = "nvim";
      PATH = "$HOME/bin:$HOME/.local/bin:$PATH";
      NVM_DIR = "$HOME/.nvm";
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
