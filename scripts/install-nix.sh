sh <(curl -L https://nixos.org/nix/install)

nix run nix-darwin -- switch --flake ./nix
darwin-rebuild switch --flake ./nix # is this unnecessary?

nix run home-manager/master -- init --switch --flake ./nix/home-manager/#kitty
