# shellcheck disable=SC2148
ORB_STR_ROLE_ARN="$(circleci env subst "${ORB_STR_ROLE_ARN}")"
ORB_STR_PROFILE_NAME="$(circleci env subst "${ORB_STR_PROFILE_NAME}")"
ORB_EVAL_SOURCE_PROFILE=$(circleci env subst "${ORB_EVAL_SOURCE_PROFILE}")
if [ ! -f "${HOME}/.aws/credentials" ]; then
    echo "Credentials not found. Run setup command before role-arn-setup."
    exit 1
fi

aws configure set profile."${ORB_STR_PROFILE_NAME}".role_arn "${ORB_STR_ROLE_ARN}"
aws configure set profile."${ORB_STR_PROFILE_NAME}".source_profile "${ORB_EVAL_SOURCE_PROFILE}"
