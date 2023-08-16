#!/bin/sh
AWS_CLI_STR_ROLE_ARN="$(echo "${AWS_CLI_STR_ROLE_ARN}" | circleci env subst)"
AWS_CLI_STR_PROFILE_NAME="$(echo "${AWS_CLI_STR_PROFILE_NAME}" | circleci env subst)"
AWS_CLI_STR_SOURCE_PROFILE="$(echo "${AWS_CLI_STR_SOURCE_PROFILE}" | circleci env subst)"


if [ ! -f "${HOME}/.aws/credentials" ]; then
    echo "Credentials not found. Run setup command before role-arn-setup."
    exit 1
fi

aws configure set profile."${AWS_CLI_STR_PROFILE_NAME}".role_arn "${AWS_CLI_STR_ROLE_ARN}"
aws configure set profile."${AWS_CLI_STR_PROFILE_NAME}".source_profile "${AWS_CLI_STR_SOURCE_PROFILE}"
