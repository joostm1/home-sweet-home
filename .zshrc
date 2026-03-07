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

# fzf
FZF_DEFAULT_OPTS='--tmux'
FZF_BASE="$HOME/.fzf"
[[ ! -d "$FZF_BASE" ]] && \
	git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_BASE" && \
		"$FZF_BASE/install" --bin --no-update-rc --no-bash --no-fish

extrabindirs=(
	~/bin
	~/.bin
	$XDG_DATA_HOME/../bin
	$FZF_BASE/bin
	/usr/local/go/bin
)
for d in "${extrabindirs[@]}"; do
	[ -d "$d" ] && PATH=$(addtopath "$d")
done

# uv package manager
UV_NATIVE_TLS=true

# oh-my-zsh
ZSH="$HOME/.oh-my-zsh"
[[ ! -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH/custom/plugins/zsh-syntax-highlighting"

ZSH_THEME="sunaku"
plugins=(
	gitfast
	zsh-autosuggestions
	zsh-syntax-highlighting
	ssh-agent
)
eval "$(zoxide init zsh)"
source $ZSH/oh-my-zsh.sh
source <($FZF_BASE/bin/fzf --zsh)

# completion
autoload -Uz compinit; compinit
zstyle ':completion:*' menu select
__c_completion() {
  eval $(env _TYPER_COMPLETE_ARGS="${words[1,$CURRENT]}" __C_COMPLETE=complete_zsh -c)
}
compdef __c_completion -c
