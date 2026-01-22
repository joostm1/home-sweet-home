# additional command search locations
[ -d ~/bin/ ] && export PATH=$PATH:~/bin
[ -d ~/.bin/ ] && export PATH=$PATH:~/.bin
[ -d ~/.local/bin/ ] && export PATH=$PATH:~/.local/bin
[ -d ~/.fzf/bin/ ] && export PATH=$PATH:~/.fzf/bin
[ -d /usr/local/go/bin ] && export PATH=$PATH:/usr/local/go/bin
# node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
UV_NATIVE_TLS=true
