# Setup fzf
# ---------
if [[ ! "$PATH" == */home/joost/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/joost/.fzf/bin"
fi

source <(fzf --zsh)
