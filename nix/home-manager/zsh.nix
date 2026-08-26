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
    initContent = ''
      autoload -U +X bashcompinit && bashcompinit
      fpath=($fpath "$HOME/.zfunctions")
      if [[ -f ~/.config/zsh/local.zsh ]]; then
        source ~/.config/zsh/local.zsh
      else
        echo "Warning: ~/.config/zsh/local.zsh not found - secrets and local config unavailable" >&2
      fi

      # nvm is brew-managed (see Brewfile). NVM_DIR holds the installed node
      # versions and is independent of how nvm itself was installed, so the
      # last candidate below still picks up a curl-installed nvm.
      export NVM_DIR="$HOME/.nvm"
      for _nvm in /opt/homebrew/opt/nvm/nvm.sh /usr/local/opt/nvm/nvm.sh "$NVM_DIR/nvm.sh"; do
        if [ -s "$_nvm" ]; then . "$_nvm"; break; fi
      done
      for _nvm in /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm \
                  /usr/local/opt/nvm/etc/bash_completion.d/nvm \
                  "$NVM_DIR/bash_completion"; do
        if [ -s "$_nvm" ]; then . "$_nvm"; break; fi
      done
      unset _nvm

      export PATH=~/.opencode/bin:$PATH

      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"

    '';
  };

  programs.zoxide.enableZshIntegration = true;
  programs.direnv.enableZshIntegration = true;
  programs.starship.enable = true;
}
