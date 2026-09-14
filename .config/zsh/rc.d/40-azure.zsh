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
