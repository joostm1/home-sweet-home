# Git helpers. Interactive fzf workflows are functions, not aliases.

alias g='git'
alias gst='git status -sb'

# Local branch → git switch
gfb() {
	git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

	local branch
	branch=$(
		git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads \
		| fzf --prompt='branch> ' --ansi \
			--preview='git log --oneline --decorate --color=always --graph -20 {1}'
	) || return

	[[ -n "$branch" ]] && git switch "$branch"
}

# Remote branch → switch, creating a local tracking branch when needed
gfr() {
	git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

	local remote_ref branch
	remote_ref=$(
		git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/remotes \
		| grep -v '/HEAD$' \
		| fzf --prompt='remote> ' --ansi \
			--preview='git log --oneline --decorate --color=always --graph -20 {1}'
	) || return

	[[ -z "$remote_ref" ]] && return
	branch="${remote_ref#*/}"
	if git show-ref --verify --quiet "refs/heads/$branch"; then
		git switch "$branch"
	else
		git switch --track "$remote_ref"
	fi
}

# Unstaged / untracked files → git add
gfa() {
	git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

	local -a files
	files=(${(f)"$(
		git ls-files -m -o --exclude-standard \
		| fzf --multi --prompt='add> ' --ansi \
			--preview='git diff --color=always -- {1} 2>/dev/null || git diff --color=always --no-index /dev/null {1}'
	)"}) || return

	(( $#files )) && git add -- "$files[@]"
}

# Stash list → git stash apply
gfs() {
	git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

	local stash
	stash=$(
		git stash list --format='%gd %s' \
		| fzf --prompt='stash> ' --ansi \
			--preview='git stash show -p --color=always {1}'
	) || return

	[[ -n "$stash" ]] && git stash apply "${stash%% *}"
}
