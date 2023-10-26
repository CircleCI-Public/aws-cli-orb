#!/bin/sh
AWS_CLI_STR_ROLE_SESSION_NAME="$(echo "${AWS_CLI_STR_ROLE_SESSION_NAME}" | circleci env subst)"
AWS_CLI_STR_ROLE_ARN="$(echo "${AWS_CLI_STR_ROLE_ARN}" | circleci env subst)"
AWS_CLI_STR_PROFILE_NAME="$(echo "${AWS_CLI_STR_PROFILE_NAME}" | circleci env subst)"
AWS_CLI_STR_REGION="$(echo "${AWS_CLI_STR_REGION}" | circleci env subst)"
AWS_CLI_INT_SESSION_DURATION="$(echo "${AWS_CLI_INT_SESSION_DURATION}" | circleci env subst)"

# Replaces white spaces in role session name with dashes
AWS_CLI_STR_ROLE_SESSION_NAME=$(echo "${AWS_CLI_STR_ROLE_SESSION_NAME}" | tr ' ' '-')
if [ -z "${AWS_CLI_STR_ROLE_SESSION_NAME}" ]; then
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

if [ -n "${AWS_CLI_STR_REGION}" ]; then
    set -- "$@" --region "${AWS_CLI_STR_REGION}"
fi

read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<EOF
$(aws sts assume-role-with-web-identity \
--role-arn "${AWS_CLI_STR_ROLE_ARN}" \
--role-session-name "${AWS_CLI_STR_ROLE_SESSION_NAME}" \
--web-identity-token "${CIRCLE_OIDC_TOKEN_V2}" \
--duration-seconds "${AWS_CLI_INT_SESSION_DURATION}" \
"$@" \
--query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
--output text)
EOF

temp_file="/tmp/${AWS_CLI_STR_PROFILE_NAME}.keys"
touch "$temp_file"

if [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ] || [ -z "${AWS_SESSION_TOKEN}" ]; then
    echo "Failed to assume role";
    exit 1
else 
    {
        echo "export AWS_CLI_STR_ACCESS_KEY_ID=\"${AWS_ACCESS_KEY_ID}\""
        echo "export AWS_CLI_STR_SECRET_ACCESS_KEY=\"${AWS_SECRET_ACCESS_KEY}\""
        echo "export AWS_CLI_STR_SESSION_TOKEN=\"${AWS_SESSION_TOKEN}\""
    }  >> "$temp_file"
    echo "Assume role with web identity succeeded"
fi
