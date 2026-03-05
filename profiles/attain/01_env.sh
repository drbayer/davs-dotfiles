export GITHUB_SSH_COMMAND='ssh -i /Users/dbayer/.ssh/github-drbayer'

# AWS RDS Hosts
export devstats=devstats.c6zdrrll14uj.us-east-2.rds.amazonaws.com
export initialstattest=initialstattest.c6zdrrll14uj.us-east-2.rds.amazonaws.com
export kloverstats=kloverstats.c6zdrrll14uj.us-east-2.rds.amazonaws.com
export PATH=$PATH:/opt/attain/bin:/opt/homebrew/opt/mysql-client/bin
export JIRA_USER=$(get_safe_value JIRA_USER)
export JIRA_USER_EMAIL=$(get_safe_value JIRA_USER)
export JIRA_TOKEN_FILE=$(get_safe_value JIRA_TOKEN_FILE)
export JIRA_TOKEN=$(head -1 "$JIRA_TOKEN_FILE")

eval "$(thefuck --alias)"

