if ! command -v nvim &> /dev/null; then
  echo "Installing Neovim..."
  brew install neovim
fi

if ! command -v gawk &> /dev/null; then
  echo "Installing gawk..."
  brew install gawk
fi

if ! command -v fzf &> /dev/null; then
  echo "Installing fzf..."
  brew install fzf
fi
