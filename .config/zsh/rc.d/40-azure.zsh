# Azure CLI shortcuts. Interactive fzf workflows are functions.

alias azacc='az account show -o table'
alias azls='az account list -o table'

# Subscription → az account set
azs() {
	command -v az >/dev/null || return

	local selection
	selection=$(
		az account list --query "[].join(' | ', [name, id])" -o tsv \
		| fzf --prompt='subscription> '
	) || return

	[[ -n "$selection" ]] && az account set --subscription "${selection##* | }"
}

# Resource group → AZURE_RESOURCE_GROUP (picked up by az / terraform)
azg() {
	command -v az >/dev/null || return

	local rg
	rg=$(
		az group list --query '[].name' -o tsv \
		| fzf --prompt='group> '
	) || return

	if [[ -n "$rg" ]]; then
		export AZURE_RESOURCE_GROUP="$rg"
		print -r -- "AZURE_RESOURCE_GROUP=$rg"
	fi
}

# Next az keyword from --help → fzf (repeat; Esc drops command into the line editor)
azc() {
	command -v az >/dev/null || return

	local -a cmd=(az)
	local selection keywords

	(( $# )) && cmd+=("$@")

	while true; do
		keywords=$(
			"${cmd[@]}" --help 2>/dev/null \
			| awk '
				/^Subgroups:|^Commands:/ { show = 1; next }
				/^[^[:space:]]/ { show = 0 }
				show && $1 ~ /^[a-z][a-z0-9-]*$/ && $2 == ":" {
					print $1
				}
			'
		) || break

		[[ -z "$keywords" ]] && break

		selection=$(
			print -r -- "$keywords" \
			| fzf --prompt="${(j: :)cmd}> " --ansi \
				--preview="${(j: :)cmd} {} --help 2>/dev/null"
		) || break

		[[ -z "$selection" ]] && break
		cmd+=("$selection")
	done

	(( $#cmd > 1 )) || return
	print -z -- "${cmd[@]}"
}
