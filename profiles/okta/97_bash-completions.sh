#!/usr/bin/env bash
# Terragrunt tab completion
complete -o nospace -C /opt/homebrew/bin/terragrunt terragrunt

# OpenTofu tab completion
complete -o nospace -C /opt/homebrew/bin/tofu tofu

# AWS CLI tab completion
complete -C '/usr/local/bin/aws_completer' aws

# k9s tab completion
. ./helpers/k9s_bash_completion.sh
