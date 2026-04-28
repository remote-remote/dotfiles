{ pkgs, remote, ... }:
{
  home = {
    packages = with pkgs; [
      starship
    ];

    sessionVariables = {
      ZSH_CUSTOM = "$HOME/.oh-my-zsh/custom";
    };

  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "vi-mode" ];
    };
    shellAliases = {
      vim = "nvim";
      vimdiff = "nvim -d";
      awk = "gawk";
      gbc = ''git branch --merged | egrep -v "(^\*|master|main|dev)" | xargs git branch -d'';
      hms = "home-manager switch --impure --flake ~/dotfiles/nix#default";
      yz = "yazi";
      cd = "z";
      lg = "lazygit";
    };
    initExtra = ''
      autoload -U +X bashcompinit && bashcompinit
      fpath=($fpath "$HOME/.zfunctions")
      if [[ -f ~/.config/zsh/local.zsh ]]; then
        source ~/.config/zsh/local.zsh
      else
        echo "Warning: ~/.config/zsh/local.zsh not found - secrets and local config unavailable" >&2
      fi

      [[ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]] && . /opt/homebrew/opt/asdf/libexec/asdf.sh

      export PATH=~/.opencode/bin:$PATH

      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"

    '';
  };

  programs.zoxide.enableZshIntegration = true;
  programs.direnv.enableZshIntegration = true;
  programs.starship.enable = true;
}
