# zsh is the final word in shells; extra snippets live in .config/zsh/rc.d

# helper to add a directory to $PATH
addtopath ()
{
	awk -v home="$HOME" -v dir="$1" -v path="$PATH" 'BEGIN {
		gsub(/^~/, home, dir)
		p = split(path, patharray, ":")
		for (i = 1; i <= p; i++) {
			if (patharray[i] == dir) {
				found = 1
				break
			}
		}
		if (found != 1)
			path = path ":" dir
		print path
	}'
}

# match the default XDG directories
XDG_DATA_HOME="$HOME/.local/share"
XDG_CONFIG_HOME="$HOME/.config"
XDG_CACHE_HOME="$HOME/.cache"
XDG_STATE_HOME="$HOME/.local/state"

# random assortment of environment variables to help our forthcoming zsh experience
XDG_BIN=$XDG_DATA_HOME/../bin # where xdg aware tools install binaries
UV_SYSTEM_CERTS=true # uv should use system certs instead of vendored ones
DBT_LOG_PATH=/tmp/dbt-logs # to prevent fdbt fusion create a logs dir in every repo
ZSH=$HOME/.oh-my-zsh # did oh-my scoop $ZSH?
ZSH_THEME=sunaku
FZF_DEFAULT_OPTS=--tmux # use fzf in tmux
FZF_BASE=$HOME/.fzf # fuzzy finder
NVM_DIR=$HOME/.nvm # where node version manager lives
UMASK=027 # remove w from group and rwx from other

# .ssh for starters
[[ ! -d $HOME/.ssh ]] && mkdir $HOME/.ssh && chmod u=rwx,g=,o= $HOME/.ssh && cat <<-EOT>$HOME/.ssh/config
	AddKeysToAgent yes

	## example azure devops
	# Host ssh.dev.azure.com
	# HostName ssh.dev.azure.com
	# IdentityFile ~/.ssh/azdevops.key
	# IdentitiesOnly yes
	# User git

	## example jump host
	# Host jumphost.example.com
	# IdentityFile ~/.ssh/jumphost.key
	# ForwardAgent yes
	# LocalForward 2200 localhost:22
EOT

# enumerate directories to be added to $PATH
extra_cmd_search_dirs=(
	~/bin
	~/.bin
	~/go/bin
	$XDG_BIN
	$FZF_BASE/bin
	~/.opencode/bin
)
for d in "${extra_cmd_search_dirs[@]}"; do
	[[ -d "$d" ]] && PATH=$(addtopath "$d")
done

plugins=(
	git
	gitfast
	zsh-autosuggestions
	zsh-syntax-highlighting
	ssh-agent
)
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
[[ -r $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh
[[ -x $FZF_BASE/bin/fzf ]] && source <($FZF_BASE/bin/fzf --zsh)
[[ -r $NVM_DIR/nvm.sh ]] && source "$NVM_DIR/nvm.sh"

# source in aliases
for rc in "$XDG_CONFIG_HOME"/zsh/rc.d/*.zsh(N); do
	source "$rc"
done

# completion
autoload -Uz compinit; compinit
zstyle ':completion:*' menu select
__c_completion() {
  eval $(env _TYPER_COMPLETE_ARGS="${words[1,$CURRENT]}" __C_COMPLETE=complete_zsh -c)
}
compdef __c_completion -c

# tmux is the default interactive workspace, but zsh remains the login shell
if [[ -o interactive && -z "$TMUX" && "$TERM" != "dumb" ]] && command -v tmux >/dev/null; then
	tmux attach-session -t main || tmux new-session -s main
fi
