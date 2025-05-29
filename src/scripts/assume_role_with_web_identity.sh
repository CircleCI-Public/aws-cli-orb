#!/bin/sh
#shellcheck disable=SC1090

# Ensure variables are loaded from $BASH_ENV as required
touch "${BASH_ENV}"
. "${BASH_ENV}"

AWS_CLI_STR_ROLE_SESSION_NAME="$(echo "${AWS_CLI_STR_ROLE_SESSION_NAME}" | circleci env subst)"
AWS_CLI_STR_ROLE_ARN="$(echo "${AWS_CLI_STR_ROLE_ARN}" | circleci env subst)"
AWS_CLI_STR_PROFILE_NAME="$(echo "${AWS_CLI_STR_PROFILE_NAME}" | circleci env subst)"
AWS_CLI_STR_REGION="$(echo "${AWS_CLI_STR_REGION}" | circleci env subst)"
AWS_CLI_INT_SESSION_DURATION="$(echo "${AWS_CLI_INT_SESSION_DURATION}" | circleci env subst)"
AWS_CLI_BOOL_SET_AWS_ENV_VARS="$(echo "${AWS_CLI_BOOL_SET_AWS_ENV_VARS}" | circleci env subst)"

AWS_CLI_STR_ROLE_SESSION_NAME=$(printf '%s' "${AWS_CLI_STR_ROLE_SESSION_NAME}" | tr -sC 'A-Za-z0-9=,.@_\-' '-')
AWS_CLI_STR_ROLE_SESSION_NAME=$(echo "${AWS_CLI_STR_ROLE_SESSION_NAME}" | cut -c -64)

if [ -z "${AWS_CLI_STR_ROLE_SESSION_NAME}" ]; then
    echo "Role session name is required"
    exit 1
fi

if [ -z "${CIRCLE_OIDC_TOKEN_V2}" ] || [ -z "${CIRCLE_OIDC_TOKEN}" ]; then
    TOKEN_SETUP_SUCCESS=false
    for i in {1..3}; do
        echo "Attempt $i: Minting OIDC tokens"
        CIRCLE_OIDC_TOKEN=$(circleci run oidc get --claims "{\"aud\":\"${CIRCLE_ORGANIZATION_ID}\"}")
        CIRCLE_OIDC_TOKEN_V2=$CIRCLE_OIDC_TOKEN
        if [ -n "$CIRCLE_OIDC_TOKEN" ] && [ ${#CIRCLE_OIDC_TOKEN} -ge 4 ]; then
            echo "Successfully set CIRCLE_OIDC_TOKEN"
            echo 'export CIRCLE_OIDC_TOKEN="'"$CIRCLE_OIDC_TOKEN"'"' >> "$BASH_ENV"
            echo 'export CIRCLE_OIDC_TOKEN_V2="'"$CIRCLE_OIDC_TOKEN_V2"'"' >> "$BASH_ENV"
            TOKEN_SETUP_SUCCESS=true
            source "$BASH_ENV"
            break
        fi
        echo "Waiting 1 second before retry"
        sleep 1
    done
    
    if [ "$TOKEN_SETUP_SUCCESS" = false ]; then
        echo "Failed to set CIRCLE_OIDC_TOKEN and CIRCLE_OIDC_TOKEN_V2 after 3 attempts. Please try rerunning the worklow."
        exit 1
    fi
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

if [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ] || [ -z "${AWS_SESSION_TOKEN}" ]; then
    echo "Failed to assume role";
    exit 1
elif [ "${AWS_CLI_BOOL_SET_AWS_ENV_VARS}" = 1 ]; then
    {
        # These are the original aws variables, and will be used when no profile is passed.
        echo "export AWS_ACCESS_KEY_ID=\"${AWS_ACCESS_KEY_ID}\""
        echo "export AWS_SECRET_ACCESS_KEY=\"${AWS_SECRET_ACCESS_KEY}\""
        echo "export AWS_SESSION_TOKEN=\"${AWS_SESSION_TOKEN}\""
        # These are used for the configure script, which will use them to configure the profile
        echo "export AWS_CLI_STR_ACCESS_KEY_ID=\"${AWS_ACCESS_KEY_ID}\""
        echo "export AWS_CLI_STR_SECRET_ACCESS_KEY=\"${AWS_SECRET_ACCESS_KEY}\""
        echo "export AWS_CLI_STR_SESSION_TOKEN=\"${AWS_SESSION_TOKEN}\""
    }  >> "$BASH_ENV"

    echo "AWS keys successfully written to BASH_ENV"
else
    temp_file="/tmp/${AWS_CLI_STR_PROFILE_NAME}.keys"
    touch "$temp_file"
    {
        echo "export AWS_CLI_STR_ACCESS_KEY_ID=\"${AWS_ACCESS_KEY_ID}\""
        echo "export AWS_CLI_STR_SECRET_ACCESS_KEY=\"${AWS_SECRET_ACCESS_KEY}\""
        echo "export AWS_CLI_STR_SESSION_TOKEN=\"${AWS_SESSION_TOKEN}\""
    }  >> "$temp_file"
    
    echo "AWS keys successfully written to ${AWS_CLI_STR_PROFILE_NAME}.keys"
fi
