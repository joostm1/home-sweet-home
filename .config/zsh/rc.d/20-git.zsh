# Git helpers: a few interactive fzf workflows, not thin aliases for git subcommands.
# Pattern: named after the subcommand, action picker first when it adds a mode, then a contextual fzf.

_git_in_repo() {
	git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

_git_file_preview='git diff --color=always -- {1} 2>/dev/null || git diff --color=always --no-index /dev/null {1}'

# Local + remote branches (newest commit first) → git switch
gsw() {
	_git_in_repo || return

	local selection branch
	selection=$(
		git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads refs/remotes \
		| grep -v '/HEAD$' \
		| fzf --prompt='switch> ' --ansi \
			--preview='git log --oneline --decorate --color=always --graph -20 {1}'
	) || return

	[[ -z "$selection" ]] && return

	if git show-ref --verify --quiet "refs/heads/$selection"; then
		git switch "$selection"
	elif git show-ref --verify --quiet "refs/remotes/$selection"; then
		branch="${selection#*/}"
		if git show-ref --verify --quiet "refs/heads/$branch"; then
			git switch "$branch"
		else
			git switch --track "$selection"
		fi
	else
		print -u2 "gsw: unknown ref '$selection'"
		return 1
	fi
}

alias gswc='git switch -c'

# log: show | hash
glog() {
	_git_in_repo || return

	local action commit
	action=$(printf 'show\nhash\n' | fzf --prompt='log> ') || return

	commit=$(
		git log --oneline --decorate --color=always \
		| fzf --prompt="log ${action}> " --ansi \
			--preview='git show --stat --patch --color=always {1}'
	) || return

	[[ -z "$commit" ]] && return
	case $action in
		show) git show "${commit%% *}" ;;
		hash) print -r -- "${commit%% *}" ;;
	esac
}

# add: files | all
gadd() {
	_git_in_repo || return

	local action
	action=$(printf 'files\nall\n' | fzf --prompt='add> ') || return

	case $action in
		files)
			local -a files
			files=(${(f)"$(
				git ls-files -m -o --exclude-standard \
				| fzf --multi --prompt='add files> ' --ansi \
					--preview="$_git_file_preview"
			)"}) || return

			(( $#files )) && git add -- "$files[@]"
			;;
		all)
			git add -A
			;;
	esac
}

# restore: worktree | staged
grestore() {
	_git_in_repo || return

	local action
	action=$(printf 'worktree\nstaged\n' | fzf --prompt='restore> ') || return

	case $action in
		worktree)
			local -a files
			files=(${(f)"$(
				git diff --name-only \
				| fzf --multi --prompt='restore worktree> ' --ansi \
					--preview='git diff --color=always -- {1}'
			)"}) || return

			(( $#files )) && git restore -- "$files[@]"
			;;
		staged)
			local -a files
			files=(${(f)"$(
				git diff --cached --name-only \
				| fzf --multi --prompt='restore staged> ' --ansi \
					--preview='git diff --cached --color=always -- {1}'
			)"}) || return

			(( $#files )) && git restore --staged -- "$files[@]"
			;;
	esac
}

# stash: push | pop
gstash() {
	_git_in_repo || return

	local action
	action=$(printf 'push\npop\n' | fzf --prompt='stash> ') || return

	case $action in
		push)
			local -a files
			files=(${(f)"$(
				git ls-files -m -o --exclude-standard \
				| fzf --multi --prompt='stash push> ' --ansi \
					--preview="$_git_file_preview"
			)"}) || return

			if (( $#files )); then
				git stash push --include-untracked -- "$files[@]"
			else
				git stash push
			fi
			;;
		pop)
			local stash
			stash=$(
				git stash list --format='%gd %s' \
				| fzf --prompt='stash pop> ' --ansi \
					--preview='git stash show -p --color=always {1}'
			) || return

			[[ -n "$stash" ]] && git stash pop "${stash%% *}"
			;;
	esac
}
