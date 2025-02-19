{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "remote.remote";
  home.homeDirectory = "/Users/remote.remote";

  home.stateVersion = "24.11"; # Don't change this

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.neovim
    pkgs.tmux
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/kitty/kitty.conf".source = ../../kitty/with-tmux.conf;
    ".config/kitty/navigator.py".source = ../../kitty/navigator.py;
    ".config/kitty/sessionizer/session.py".source = ../../kitty/sessionizer/session.py;
    ".config/kitty/resizer.py".source = ../../kitty/resizer.py;
    ".config/kitty/kitty-themes".source = ../../kitty/kitty-themes;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/remote.remote/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    TEST_VAR = "jason";
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
