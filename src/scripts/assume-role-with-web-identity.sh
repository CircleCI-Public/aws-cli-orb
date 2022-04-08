PARAM_ROLE_SESSION_NAME=$(eval echo "\$$PARAM_ROLE_SESSION_NAME")

echo "${PARAM_ROLE_SESSION_NAME}" >> test.txt
echo "${PARAM_AWS_CLI_ROLE_ARN}" >> test.txt
echo "$CIRCLE_OIDC_TOKEN" >> test.txt
echo "${PARAM_SESSION_DURATION}" >> test.txt
read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< \
$(aws sts assume-role-with-web-identity \
--role-arn ${PARAM_AWS_CLI_ROLE_ARN} \
--role-session-name "${PARAM_ROLE_SESSION_NAME}" \
--web-identity-token $CIRCLE_OIDC_TOKEN \
--duration-seconds "${PARAM_SESSION_DURATION}" \
--query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
--output text)
# aws sts get-caller-identity

echo "this works" >> test.txt

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID 
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

echo "AKI ${AWS_ACCESS_KEY_ID}" >> test.txt
echo "SAC ${AWS_SECRET_ACCESS_KEY}" >> test.txt
echo "ST ${AWS_SESSION_TOKEN}" >> test.txt

