# Terraform shortcuts. Interactive fzf workflows are functions.

alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt -recursive'
alias tfo='terraform output'

# Workspace → terraform workspace select
tfw() {
	command -v terraform >/dev/null || return

	local ws
	ws=$(
		terraform workspace list 2>/dev/null \
		| sed 's/^[* ]*//' \
		| grep -v '^$' \
		| fzf --prompt='workspace> '
	) || return

	[[ -n "$ws" ]] && terraform workspace select "$ws"
}
