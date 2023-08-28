# shellcheck disable=SC2148
AWS_CLI_STR_AWS_CLI_VERSION="$(echo "${AWS_CLI_STR_AWS_CLI_VERSION}" | circleci env subst)"
AWS_CLI_EVAL_INSTALL_DIR="$(eval echo "${AWS_CLI_EVAL_INSTALL_DIR}" | circleci env subst)"
AWS_CLI_EVAL_BINARY_DIR="$(eval echo "${AWS_CLI_EVAL_BINARY_DIR}" | circleci env subst)"

if grep "Alpine" /etc/issue >/dev/null 2>&1; then
    if [ "$ID" = 0 ]; then export SUDO=""; else export SUDO="sudo"; fi
else
    if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi
fi

eval "$SCRIPT_UTILS"
detect_os

# Install per platform
case $SYS_ENV_PLATFORM in
linux)
    eval "$SCRIPT_BUILD_LINUX"
    ;;
windows)
    eval "$SCRIPT_BUILD_WINDOWS"
    ;;
macos)
    eval "$SCRIPT_BUILD_MACOS"
    ;;
*)
    echo "This orb does not currently support your platform. If you believe it should, please consider opening an issue on the GitHub repository:"
    echo "https://github.com/CircleCI-Public/aws-cli-orb/issues/new"
    exit 1
    ;;
esac

Toggle_Pager(){
    # Toggle AWS Pager
    if [ "$AWS_CLI_BOOL_DISABLE_PAGER" -eq 1 ]; then
        if [ -z "${AWS_PAGER+x}" ]; then
            echo 'export AWS_PAGER=""' >>"$BASH_ENV"
            echo "AWS_PAGER is being set to the empty string to disable all output paging for AWS CLI commands."
            echo "You can set the 'disable-aws-pager' parameter to 'false' to disable this behavior."
        fi
    fi
}

if [ ! "$(command -v aws)" ]; then
    if [ "$AWS_CLI_STR_AWS_CLI_VERSION" = "latest" ]; then
        Install_AWS_CLI ""
    else
        if [ "${SYS_ENV_PLATFORM}" = "windows" ]; then
            Install_AWS_CLI "${AWS_CLI_STR_AWS_CLI_VERSION}"
        else
            Install_AWS_CLI "-${AWS_CLI_STR_AWS_CLI_VERSION}"
        fi
    fi
    Toggle_Pager
elif [ "$AWS_CLI_BOOL_OVERRIDE" -eq 1 ]; then
    Uninstall_AWS_CLI
    if [ "$AWS_CLI_STR_AWS_CLI_VERSION" = "latest" ]; then
        Install_AWS_CLI ""
    else
        if [ "${SYS_ENV_PLATFORM}" = "windows" ]; then
            Install_AWS_CLI "${AWS_CLI_STR_AWS_CLI_VERSION}"
        else
            Install_AWS_CLI "-${AWS_CLI_STR_AWS_CLI_VERSION}"
        fi
    fi
    Toggle_Pager
else
    echo "AWS CLI is already installed, skipping installation."
    aws --version
fi
