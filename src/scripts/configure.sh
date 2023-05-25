#!/bin/sh
if grep "Alpine" /etc/issue > /dev/null 2>&1; then
    . "$BASH_ENV"
fi

ORB_ENV_ACCESS_KEY_ID=$(circleci env subst "\$$ORB_ENV_ACCESS_KEY_ID")
ORB_ENV_SECRET_ACCESS_KEY=$(circleci env subst "\$$ORB_ENV_SECRET_ACCESS_KEY")
ORB_EVAL_AWS_CLI_REGION=$(circleci env subst "\$$ORB_EVAL_AWS_CLI_REGION")
ORB_EVAL_PROFILE_NAME=$(circleci env subst "$ORB_EVAL_PROFILE_NAME")

if [ -z "$ORB_ENV_ACCESS_KEY_ID" ] || [ -z "${ORB_ENV_SECRET_ACCESS_KEY}" ]; then 
    echo "Cannot configure profile. AWS access key id and AWS secret access key must be provided."
    exit 1
fi

aws configure set aws_access_key_id \
    "$ORB_ENV_ACCESS_KEY_ID" \
    --profile "$ORB_EVAL_PROFILE_NAME"

aws configure set aws_secret_access_key \
    "$ORB_ENV_SECRET_ACCESS_KEY" \
    --profile "$ORB_EVAL_PROFILE_NAME"

if [ -n "${AWS_SESSION_TOKEN}" ]; then
    aws configure set aws_session_token \
        "${AWS_SESSION_TOKEN}" \
        --profile "$ORB_EVAL_PROFILE_NAME"
fi

if [ "$ORB_VAL_CONFIG_DEFAULT_REGION" = "1" ]; then
    aws configure set default.region "$ORB_EVAL_AWS_CLI_REGION" \
        --profile "$ORB_EVAL_PROFILE_NAME"
fi

if [ "$ORB_VAL_CONFIG_PROFILE_REGION" = "1" ]; then
    aws configure set region "$ORB_EVAL_AWS_CLI_REGION" \
        --profile "$ORB_EVAL_PROFILE_NAME"
fi
