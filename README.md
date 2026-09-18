# home-sweet-home

Dotfiles for a zsh + tmux workstation.

[`.zshrc`](.zshrc) is the login/interactive shell. On first run it bootstraps oh-my-zsh, fzf, uv, zoxide, nvm, and a few CLI tools, then attaches to a `main` tmux session. Extra snippets live in [`.config/zsh/rc.d/`](.config/zsh/rc.d/) (aliases, git/fzf helpers, terraform, azure) and are sourced independently. [`.tmux.conf`](.tmux.conf) is the matching tmux layout.

This tree is meant to be copied into `$HOME`. Git only tracks an allowlist (see [`.gitignore`](.gitignore)); everything else in a real home directory stays untracked.

## Installation

Clone this repo, `cd` into it, then pick one. Skip `.git` and `.gitignore` — the latter is a repo allowlist, not something you want as `$HOME/.gitignore`. Copies overwrite existing dest files and leave extra files in `$HOME` alone.

**rsync** (Ubuntu Desktop/Server 24.04 include it; minimal cloud images may not):

```sh
rsync -a --exclude .git --exclude .gitignore --exclude README.md ./ "$HOME/"
```

**cp** (always available):

```sh
cp -a .zshrc .tmux.conf "$HOME/"
mkdir -p "$HOME/.config/zsh/rc.d"
cp -a .config/zsh/rc.d/*.zsh "$HOME/.config/zsh/rc.d/"
```

**git checkout-index** (only the tracked files, then drop the repo-only ones):

```sh
git checkout-index -a --prefix="$HOME/"
rm -f "$HOME/.gitignore" "$HOME/README.md"
```

**symlinks** (keep the clone as the source of truth):

```sh
ln -sfn "$PWD/.zshrc" "$HOME/.zshrc"
ln -sfn "$PWD/.tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$HOME/.config/zsh"
ln -sfn "$PWD/.config/zsh/rc.d" "$HOME/.config/zsh/rc.d"
```

Open a new zsh session (or `exec zsh`) so `.zshrc` can finish installing tools.
