{ remote, pkgs, ...}:
let
  kittyConfig = path: {
    source = path;
    onChange = "kill -SIGUSR1 $KITTY_PID";
  };
in
  let
    multiplexerConfig = {
      kitty = {
        packages = [];
        file = {
          ".config/kitty/dynamic/tmux-emulator.conf" = kittyConfig ../../kitty/tmux-emulator.conf;
          ".config/kitty/navigator.py" = kittyConfig ../../kitty/navigator.py;
          ".config/kitty/sessionizer/session.py" = kittyConfig ../../kitty/sessionizer/session.py;
          ".config/kitty/resizer.py" = kittyConfig ../../kitty/resizer.py;
        };
      };
      tmux = {
        packages = [pkgs.tmux];
        # tmux-sessionizer is stow-managed (the `bin` package) rather than
        # written from the nix store: home-manager and stow both targeting
        # ~/.local/bin/tmux-sessionizer made `stow bin` abort on a conflict,
        # which broke re-runs of scripts/install.sh.
        file = { };
      };
    };
  in {
    home = multiplexerConfig."${remote.multiplexer}";
  }

