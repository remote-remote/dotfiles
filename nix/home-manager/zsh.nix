{ pkgs, remote, ... }:
{
  home = {
    packages = with pkgs; [
      starship
    ];

    file = {
      ".config/zsh/dev.zsh".source = ../../zsh/dev.zsh;
    };

    sessionVariables = {
      ZSH_CUSTOM = "$HOME/.oh-my-zsh/custom";
    };

  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
    shellAliases = {
      vim = "nvim";
      vimdiff = "nvim -d";
      awk = "gawk";
      gbc = ''git branch --merged | egrep -v "(^\*|master|main|dev)" | xargs git branch -d'';
      hms = "home-manager switch --flake ~/dotfiles/nix";
      drb = "darwin-rebuild switch --flake ~/dotfiles/nix";
    };
    initExtra = ''
      autoload -U +X bashcompinit && bashcompinit
      fpath=($fpath "$HOME/.zfunctions")
      if [[ -f ~/.config/zsh/local.zsh ]]; then
        source ~/.config/zsh/local.zsh
      else
        echo "Warning: ~/.config/zsh/local.zsh not found - secrets and local config unavailable" >&2
      fi
      source ~/.config/zsh/dev.zsh
      export PATH=~/.npm-packages/bin:$PATH
      export NODE_PATH=~/.npm-packages/lib/node_modules
    '';
  };

  programs.zoxide.enableZshIntegration = true;
  programs.direnv.enableZshIntegration = true;
  programs.starship.enable = true;
}
