# additional command search locations
echo "\
~/bin
~/.local/bin
/usr/local/go/bin
" | while read d
do
	[[ -d $d ]] && export PATH=$PATH:$d
done

# node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
UV_NATIVE_TLS=true
