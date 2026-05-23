# since zsh is the final word in shells, there's only file: .zshrc.this()

# helper to add a directory to $PATH if it's not already there
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

# random assortment of environment variables
XDG_BIN=$XDG_DATA_HOME/../bin # where xdg aware tools install binaries
UV_SYSTEM_CERTS=true # uv should use system certs instead of vendored ones
DBT_LOG_PATH=/tmp/dbt-logs # to prevent dbt fusion create a logs dir in every repo
ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="sunaku"
FZF_DEFAULT_OPTS='--tmux' # use fzf in tmux
FZF_BASE="$HOME/.fzf" # fuzzy finder

# install favorite tools
## oh-my
[[ ! -d "$ZSH" ]] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
## syntax highlighting
[[ ! -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH/custom/plugins/zsh-syntax-highlighting
## autosuggestions
[[ ! -d "$ZSH/custom/plugins/zsh-autosuggestions" ]] && git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH/custom/plugins/zsh-autosuggestions
## Fuzzy finder
[[ ! -d "$FZF_BASE" ]] && git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_BASE" && "$FZF_BASE/install" --bin --no-update-rc --no-bash --no-fish
## uv
[[ ! -x "$XDG_BIN/uv" ]] && curl -LsSf https://astral.sh/uv/install.sh | sh
## opencode
[[ ! -x "$HOME/.opencode/bin/opencode" ]] && curl -fsSL https://opencode.ai/install | bash
## zoxide directory jumper
[[ ! -x "$XDG_BIN/zoxide" ]] && curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
## snow cli
[[ ! -d $("$XDG_BIN/uv" tool dir)/snowflake-cli ]] && "$XDG_BIN/uv" tool install snowflake-cli

# enumerate directories to be added to $PATH
extra_cmd_search_dirs=(
	~/bin
	~/.bin
	$XDG_BIN
	$FZF_BASE/bin
	/usr/local/go/bin
	~/.opencode/bin
)
for d in "${extra_cmd_search_dirs[@]}"; do
	[[ -d "$d" ]] && PATH=$(addtopath "$d")
done

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
