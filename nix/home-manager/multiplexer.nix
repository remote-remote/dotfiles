{ multiplexer, pkgs, ...}:
let
  multiplexerConfig = {
    kitty = {
      packages = [];
      file = {
        ".config/kitty/kitty.conf".source = ../../kitty/no-tmux.conf;
        ".config/kitty/navigator.py".source = ../../kitty/navigator.py;
        ".config/kitty/sessionizer/session.py".source = ../../kitty/sessionizer/session.py;
        ".config/kitty/resizer.py".source = ../../kitty/resizer.py;
      };
    };
    tmux = {
      packages = [pkgs.tmux];
      file = {
        ".config/kitty/kitty.conf".source = ../../kitty/with-tmux.conf;
      };
    };
  };
in {
  home = multiplexerConfig."${multiplexer}";
}
