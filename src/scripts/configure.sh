#!/bin/sh
#shellcheck disable=SC1090
if grep "Alpine" /etc/issue > /dev/null 2>&1; then
    touch "$BASH_ENV"
    . "$BASH_ENV"
fi

AWS_CLI_STR_ACCESS_KEY_ID="$(echo "\$$AWS_CLI_STR_ACCESS_KEY_ID" | circleci env subst)"
AWS_CLI_STR_SECRET_ACCESS_KEY="$(echo "\$$AWS_CLI_STR_SECRET_ACCESS_KEY" | circleci env subst)"
AWS_SESSION_TOKEN="$(echo "$AWS_SESSION_TOKEN" | circleci env subst)"
AWS_CLI_STR_REGION="$(echo "$AWS_CLI_STR_REGION" | circleci env subst)"
AWS_CLI_STR_PROFILE_NAME="$(echo "$AWS_CLI_STR_PROFILE_NAME" | circleci env subst)"

if [ -z "$AWS_CLI_STR_ACCESS_KEY_ID" ] || [ -z "${AWS_CLI_STR_SECRET_ACCESS_KEY}" ]; then 
    echo "Cannot configure profile. AWS access key id and AWS secret access key must be provided."
    exit 1
fi

aws configure set aws_access_key_id \
    "$AWS_CLI_STR_ACCESS_KEY_ID" \
    --profile "$AWS_CLI_STR_PROFILE_NAME"

aws configure set aws_secret_access_key \
    "$AWS_CLI_STR_SECRET_ACCESS_KEY" \
    --profile "$AWS_CLI_STR_PROFILE_NAME"

if [ -n "${AWS_SESSION_TOKEN}" ]; then
    aws configure set aws_session_token \
        "${AWS_SESSION_TOKEN}" \
        --profile "$AWS_CLI_STR_PROFILE_NAME"
fi


if [ "$AWS_CLI_BOOL_CONFIG_DEFAULT_REGION" -eq "1" ]; then
    aws configure set default.region "$AWS_CLI_STR_REGION"
fi

if [ "$AWS_CLI_BOOL_CONFIG_PROFILE_REGION" -eq "1" ]; then
    aws configure set region "$AWS_CLI_STR_REGION" \
        --profile "$AWS_CLI_STR_PROFILE_NAME"
fi
