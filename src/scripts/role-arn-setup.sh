
if [ ! -f "${HOME}/.aws/credentials" ]; then
    echo "Credentials not found. Run setup command before role-arn-setup."
    exit 1
fi
    
aws configure set profile."${PARAM_AWS_CLI_PROFILE_NAME}".role_arn "${PARAM_AWS_CLI_ROLE_ARN}"
aws configure set profile."${PARAM_AWS_CLI_PROFILE_NAME}".source_profile "${PARAM_AWS_CLI_SOURCE_PROFILE}"
