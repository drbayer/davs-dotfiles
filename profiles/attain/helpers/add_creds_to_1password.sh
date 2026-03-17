#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] -u <username>

Reads AWS Secrets Manager credentials for an IAM user and creates a
1Password item so the credentials can be shared with the user.

The secret is read from /users/<username> in Secrets Manager and must
contain the following keys:
  username          IAM username
  initial_password  Temporary password
  login_url         AWS console login URL

OPTIONS:
  -u <username>   IAM username (required)
  -v <vault>      1Password vault to store the item in (default: Employee)
  -t <title>      Title for the 1Password item (default: AWS Initial Credentials - <username>)
  -h              Show this help message and exit

EXAMPLES:
  $(basename "$0") -u jdoe
  $(basename "$0") -u jdoe -v "Shared" -t "AWS IAM - jdoe"
EOF
}

VAULT="Employee"
USERNAME=""
TITLE=""

while getopts ":u:v:t:h" opt; do
  case $opt in
    u) USERNAME="$OPTARG" ;;
    v) VAULT="$OPTARG" ;;
    t) TITLE="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Error: option -$OPTARG requires an argument." >&2; usage; exit 1 ;;
    \?) echo "Error: unknown option -$OPTARG" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$USERNAME" ]]; then
  echo "Error: -u <username> is required." >&2
  usage
  exit 1
fi

TITLE="${TITLE:-AWS Initial Credentials - $USERNAME}"
SECRET_ID="/users/$USERNAME"

echo "Fetching secret '$SECRET_ID' from AWS Secrets Manager..."
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --query SecretString \
  --output text) || {
    echo "Error: failed to retrieve secret '$SECRET_ID'." >&2
    exit 1
  }

secret_field() {
  echo "$SECRET_JSON" | jq -r ".$1"
}

IAM_USERNAME=$(secret_field "username")
INITIAL_PASSWORD=$(secret_field "initial_password")
LOGIN_URL=$(secret_field "login_url")

echo "Creating 1Password item '$TITLE' in vault '$VAULT'..."
op item create \
  --category login \
  --title "$TITLE" \
  --vault "$VAULT" \
  "username=$IAM_USERNAME" \
  "password=$INITIAL_PASSWORD" \
  "website=$LOGIN_URL" \
  "notes=Initial credentials for AWS IAM user '$IAM_USERNAME'. You will be required to change your password on initial login." \
  > /dev/null || {
    echo "Error: failed to create 1Password item." >&2
    exit 1
  }

echo "Done. 1Password item '$TITLE' created in vault '$VAULT'."
