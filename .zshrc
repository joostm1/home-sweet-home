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
while read extrabindir
do
	PATH=$(addtopath $extrabindir)
done < ~/.extrabindirs

# match the default XDG directories
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

export UV_NATIVE_TLS=true

# zsh and friends
export ZSH="$HOME/.oh-my-zsh"
export FZF_BASE="$HOME/.fzf"
export FZF_DEFAULT_OPTS='--tmux'
ZSH_THEME="sunaku"
plugins=(
	gitfast
	zsh-autosuggestions
	fast-syntax-highlighting
)
eval "$(zoxide init zsh)"
source $ZSH/oh-my-zsh.sh
source <($FZF_BASE/bin/fzf --zsh)

fpath+=~/.zfunc; autoload -Uz compinit; compinit

zstyle ':completion:*' menu select
#compdef -c

__c_completion() {
  eval $(env _TYPER_COMPLETE_ARGS="${words[1,$CURRENT]}" __C_COMPLETE=complete_zsh -c)
}

compdef __c_completion -c
