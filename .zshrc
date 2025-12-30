export ZSH="$HOME/.oh-my-zsh"
export FZF_BASE="HOME"/.fzf
ZSH_THEME="sunaku"
plugins=(
	gitfast
	zsh-autosuggestions
	fast-syntax-highlighting
)
eval "$(zoxide init zsh)"
source $ZSH/oh-my-zsh.sh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

fpath+=~/.zfunc; autoload -Uz compinit; compinit

# fzf options
export FZF_DEFAULT_OPTS='--tmux'

zstyle ':completion:*' menu select
#compdef -c

__c_completion() {
  eval $(env _TYPER_COMPLETE_ARGS="${words[1,$CURRENT]}" __C_COMPLETE=complete_zsh -c)
}

compdef __c_completion -c
