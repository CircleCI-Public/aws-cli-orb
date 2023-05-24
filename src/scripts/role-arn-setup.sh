ORB_EVAL_ROLE_ARN=$(eval echo "${ORB_EVAL_ROLE_ARN}")
ORB_EVAL_PROFILE_NAME=$(eval echo "${ORB_EVAL_PROFILE_NAME}")
ORB_EVAL_SOURCE_PROFILE=$(eval echo "${ORB_EVAL_SOURCE_PROFILE}")
if [ ! -f "${HOME}/.aws/credentials" ]; then
    echo "Credentials not found. Run setup command before role-arn-setup."
    exit 1
fi

aws configure set profile."${ORB_EVAL_PROFILE_NAME}".role_arn "${ORB_EVAL_ROLE_ARN}"
aws configure set profile."${ORB_EVAL_PROFILE_NAME}".source_profile "${ORB_EVAL_SOURCE_PROFILE}"
