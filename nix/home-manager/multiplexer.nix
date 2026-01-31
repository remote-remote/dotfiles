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
        file = {
          ".local/bin/tmux-sessionizer".source = ../../bin/.local/bin/tmux-sessionizer;
        # todo: tmux config files
        };
      };
    };
  in {
    home = multiplexerConfig."${remote.multiplexer}";
  }

