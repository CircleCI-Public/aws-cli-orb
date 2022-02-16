PARAM_AWS_CLI_ACCESS_KEY_ID=$(eval echo "\$$PARAM_AWS_CLI_ACCESS_KEY_ID")
PARAM_AWS_CLI_SECRET_ACCESS_KEY=$(eval echo "\$$PARAM_AWS_CLI_SECRET_ACCESS_KEY")
PARAM_AWS_CLI_REGION=$(eval echo "\$$PARAM_AWS_CLI_REGION")
PARAM_AWS_CLI_ROLE_ARN=$(eval echo "${PARAM_AWS_CLI_ROLE_ARN}")

aws configure set aws_access_key_id \
    "$PARAM_AWS_CLI_ACCESS_KEY_ID" \
    --profile "$PARAM_AWS_CLI_PROFILE_NAME"
aws configure set aws_secret_access_key \
    "$PARAM_AWS_CLI_SECRET_ACCESS_KEY" \
    --profile "$PARAM_AWS_CLI_PROFILE_NAME"

if [ "$PARAM_AWS_CLI_CONFIG_DEFAULT_REGION" = "1" ]; then
    aws configure set default.region "$PARAM_AWS_CLI_REGION" \
        --profile "$PARAM_AWS_CLI_PROFILE_NAME"
fi

if [ "$PARAM_AWS_CLI_CONFIG_PROFILE_REGION" = "1" ]; then
    aws configure set region "$PARAM_AWS_CLI_REGION" \
        --profile "$PARAM_AWS_CLI_PROFILE_NAME"
fi

if [ -n "$PARAM_AWS_CLI_ROLE_ARN" ]; then
    aws configure set role_arn "$PARAM_AWS_CLI_ROLE_ARN" \
        --profile "$PARAM_AWS_CLI_PROFILE_NAME"
fi
