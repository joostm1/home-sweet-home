# home-sweet-home

Dotfiles for a zsh + tmux workstation.

[`.zshrc`](.zshrc) is the login/interactive shell and attaches to a `main` tmux session. Extra snippets live in [`.config/zsh/rc.d/`](.config/zsh/rc.d/) (aliases, git/fzf helpers, terraform, azure) and are sourced independently. [`.tmux.conf`](.tmux.conf) is the matching tmux layout.

This tree is meant to be copied into `$HOME`. Git only tracks an allowlist (see [`.gitignore`](.gitignore)); everything else in a real home directory stays untracked.

## Installation from the remote repo

```sh
curl -LsSf https://raw.githubusercontent.com/joostm1/home-sweet-home/main/install | zsh
```

## Installation from a local checkout

```sh
./install
```
