#!/bin/bash
PARAM_ROLE_SESSION_NAME=$(eval echo "${PARAM_ROLE_SESSION_NAME}")

# shellcheck disable=SC2086,SC2034
read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< "$(aws sts assume-role-with-web-identity \
    --role-arn ${PARAM_AWS_CLI_ROLE_ARN} \
    --role-session-name ${PARAM_ROLE_SESSION_NAME} \
    --web-identity-token ${CIRCLE_OIDC_TOKEN} \
    --duration-seconds ${PARAM_SESSION_DURATION} \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text)"

echo 'export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN' >> "$BASH_ENV" 

aws sts get-caller-identity

# aws configure set aws_access_key_id \
#     "$AWS_ACCESS_KEY_ID" \
#     --profile "$PARAM_AWS_CLI_PROFILE_NAME"

# aws configure set aws_secret_access_key \
#     "$AWS_SECRET_ACCESS_KEY" \
#     --profile "$PARAM_AWS_CLI_PROFILE_NAME"

# aws configure set aws_session_token \
#     "${AWS_SESSION_TOKEN}" \
#      --profile "$PARAM_AWS_CLI_PROFILE_NAME"

# echo "Web Identity prolie configured for profile name: ${PARAM_AWS_CLI_PROFILE_NAME}"





