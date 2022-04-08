PARAM_ROLE_SESSION_NAME=$(eval echo "\$$PARAM_ROLE_SESSION_NAME")

echo "${PARAM_ROLE_SESSION_NAME}"

read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< \
$(aws sts assume-role-with-web-identity \
--role-arn ${PARAM_AWS_CLI_ROLE_ARN} \
--role-session-name "${PARAM_ROLE_SESSION_NAME}" \
--web-identity-token $CIRCLE_OIDC_TOKEN \
--duration-seconds "${PARAM_SESSION_DURATION}" \
--query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
--output text)

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
aws sts get-caller-identity

echo "AKI ${AWS_ACCESS_KEY_ID}"
echo "SAC ${AWS_SECRET_ACCESS_KEY}"
echo "ST ${AWS_SESSION_TOKEN}"


# aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile "B-VU"
# aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile "B-VU"
# aws configure set aws_session_token $AWS_SESSION_TOKEN --profile "B-VU"
