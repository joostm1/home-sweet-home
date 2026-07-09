# since zsh is the final word in shells, there's only file: .zshrc.this()

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

# fetch favorites
## oh-my
[[ ! -d $ZSH ]] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
## syntax highlighting
[[ ! -d $ZSH/custom/plugins/zsh-syntax-highlighting ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH/custom/plugins/zsh-syntax-highlighting
## autosuggestions
[[ ! -d $ZSH/custom/plugins/zsh-autosuggestions ]] && git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH/custom/plugins/zsh-autosuggestions
## Fuzzy finder
[[ ! -d $FZF_BASE ]] && git clone --depth 1 https://github.com/junegunn/fzf.git $FZF_BASE && $FZF_BASE/install --bin --no-update-rc --no-bash --no-fish
## uv
[[ ! -x $XDG_BIN/uv ]] && curl -LsSf https://astral.sh/uv/install.sh | sh
UV_TOOL_DIR=$($XDG_BIN/uv tool dir)
## opencode
[[ ! -x $HOME/.opencode/bin/opencode ]] && curl -fsSL https://opencode.ai/install | bash
## zoxide directory jumper
[[ ! -x $XDG_BIN/zoxide ]] && curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
## snow cli
[[ ! -z $UV_TOOL_DIR ]] && [[ ! -d $UV_TOOL_DIR/snowflake-cli ]] && $XDG_BIN/uv tool install snowflake-cli
## dbt-core -- who can go without it?
[[ ! -z $UV_TOOL_DIR ]] && [[ ! -d $UV_TOOL_DIR/dbt-core ]] && $XDG_BIN/uv tool install dbt-core --with dbt-postgres,dbt-snowflake --python 3.13 && ln -fs $UV_TOOL_DIR/dbt-core/bin/dbt $XDG_BIN/dbt-core
## tmux plugins
[[ ! -d $HOME/.tmux/plugins/tpm ]] && git clone https://github.com/tmux-plugins/tpm.git $HOME/.tmux/plugins/tpm && $HOME/.tmux/plugins/tpm/bin/install_plugins
## node version manager
[[ ! -d $NVM_DIR ]] && git clone https://github.com/nvm-sh/nvm.git $NVM_DIR

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
source "$NVM_DIR/nvm.sh"  # This loads nvm

# completion
autoload -Uz compinit; compinit
zstyle ':completion:*' menu select
__c_completion() {
  eval $(env _TYPER_COMPLETE_ARGS="${words[1,$CURRENT]}" __C_COMPLETE=complete_zsh -c)
}
compdef __c_completion -c
