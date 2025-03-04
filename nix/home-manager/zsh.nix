{ pkgs, remote, ... }:
{
  home = {
    packages = with pkgs; [
      spaceship-prompt
    ];

    file = {
      ".config/zsh/dev.zsh".source = ../../zsh/dev.zsh;
      ".oh-my-zsh/custom/themes/spaceship.zsh-theme".source = "${pkgs.spaceship-prompt}/share/zsh/themes/spaceship.zsh-theme";
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
      theme = "spaceship";  # Oh My Zsh will find it in custom/themes/
    };
    shellAliases = {
      vim = "nvim";
      vimdiff = "nvim -d";
      awk = "gawk";
      gbc = ''git branch --merged | egrep -v "(^\*|master|main|dev)" | xargs git branch -d'';
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
      eval "$(direnv hook zsh)"  # Enable direnv in Zsh
    '';
    profileExtra = ''
      ${if remote.brew.nvm then 
        ''
          [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
          [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
        '' else ""}
      ${if remote.brew.rbenv then ''eval "$(rbenv init - --no-rehash zsh)"'' else ""}
    '';
  };

  programs.zoxide.enableZshIntegration = true;
}
