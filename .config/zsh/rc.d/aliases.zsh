# General interactive aliases. Tool-specific snippets live in sibling files.

alias ll='ls -lah'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'

alias grep='grep --color=auto'

# dbt logs live in /tmp (see DBT_LOG_PATH in .zshrc)
alias dbtlogs='ls -lt "${DBT_LOG_PATH:-/tmp/dbt-logs}"'
