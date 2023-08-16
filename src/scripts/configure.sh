#!/bin/sh
#shellcheck disable=SC1090
if grep "Alpine" /etc/issue > /dev/null 2>&1; then
    touch "$BASH_ENV"
    . "$BASH_ENV"
fi

ORB_STR_ACCESS_KEY_ID="$(echo "$ORB_STR_ACCESS_KEY_ID" | circleci env subst)"
ORB_STR_SECRET_ACCESS_KEY="$(echo "$ORB_STR_SECRET_ACCESS_KEY" | circleci env subst)"
AWS_SESSION_TOKEN="$(echo "$AWS_SESSION_TOKEN" | circleci env subst)"
ORB_STR_REGION="$(echo "$ORB_STR_REGION" | circleci env subst)"
ORB_STR_PROFILE_NAME="$(echo "$ORB_STR_PROFILE_NAME" | circleci env subst)"

if [ -z "$ORB_STR_ACCESS_KEY_ID" ] || [ -z "${ORB_STR_SECRET_ACCESS_KEY}" ]; then 
    echo "Cannot configure profile. AWS access key id and AWS secret access key must be provided."
    exit 1
fi

aws configure set aws_access_key_id \
    "$ORB_STR_ACCESS_KEY_ID" \
    --profile "$ORB_STR_PROFILE_NAME"

aws configure set aws_secret_access_key \
    "$ORB_STR_SECRET_ACCESS_KEY" \
    --profile "$ORB_STR_PROFILE_NAME"

if [ -n "${AWS_SESSION_TOKEN}" ]; then
    aws configure set aws_session_token \
        "${AWS_SESSION_TOKEN}" \
        --profile "$ORB_STR_PROFILE_NAME"
fi


if [ "$ORB_BOOL_CONFIG_DEFAULT_REGION" -eq "1" ]; then
    aws configure set default.region "$ORB_STR_REGION"
fi

if [ "$ORB_BOOL_CONFIG_PROFILE_REGION" -eq "1" ]; then
    aws configure set region "$ORB_STR_REGION" \
        --profile "$ORB_STR_PROFILE_NAME"
fi
