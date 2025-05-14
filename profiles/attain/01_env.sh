export GITHUB_SSH_COMMAND='ssh -i /Users/dbayer/.ssh/github-drbayer'

# AWS RDS Hosts
export initialstattest=initialstattest.c6zdrrll14uj.us-east-2.rds.amazonaws.com
export kloverstats=kloverstats.c6zdrrll14uj.us-east-2.rds.amazonaws.com
export PATH=$PATH:/opt/attain/bin:/opt/homebrew/opt/mysql-client/bin

eval "$(thefuck --alias)"

# gsutil requires python 3.12 or earlier, but system python is 3.13
# /opt/homebrew/opt/python@3.12/bin/python3.12 -m venv gsutil_env
alias gsutil='. ~/tmp/gsutil/gsutil_env/bin/activate; gsutil'

# we use many versions of terraform in sre-infrastructure and using a
# newer version can cause grief. Use tfenv to compensate.
. "$DOTFILES_BASEDIR/profiles/active/helpers/terraform.sh"
alias terraform='set_tf_version; terraform'
