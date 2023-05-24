PARAM_ROLE_SESSION_NAME=$(eval echo "${PARAM_ROLE_SESSION_NAME}")
PARAM_AWS_CLI_ROLE_ARN=$(eval echo "${PARAM_AWS_CLI_ROLE_ARN}")

if [ -z "${PARAM_ROLE_SESSION_NAME}" ]; then
    echo "Role session name is required"
    exit 1
fi

if [ -z "${CIRCLE_OIDC_TOKEN_V2}" ]; then
    echo "OIDC Token cannot be found. A CircleCI context must be specified."
    exit 1
fi

if [ ! "$(command -v aws)" ]; then
    echo "AWS CLI is not installed. Please run the setup or install command first."
    exit 1
fi

read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<EOF
$(aws sts assume-role-with-web-identity \
--role-arn "${PARAM_AWS_CLI_ROLE_ARN}" \
--role-session-name "${PARAM_ROLE_SESSION_NAME}" \
--web-identity-token "${CIRCLE_OIDC_TOKEN_V2}" \
--duration-seconds "${PARAM_SESSION_DURATION}" \
--query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
--output text)
EOF

if [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ] || [ -z "${AWS_SESSION_TOKEN}" ]; then
    echo "Failed to assume role";
    exit 1
else 
    {
        echo "export AWS_ACCESS_KEY_ID=\"${AWS_ACCESS_KEY_ID}\""
        echo "export AWS_SECRET_ACCESS_KEY=\"${AWS_SECRET_ACCESS_KEY}\""
        echo "export AWS_SESSION_TOKEN=\"${AWS_SESSION_TOKEN}\""
    } >>"$BASH_ENV"
    echo "Assume role with web identity succeeded"
fi