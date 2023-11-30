#!/bin/sh
AWS_CLI_STR_AWS_CLI_VERSION="$(echo "${AWS_CLI_STR_AWS_CLI_VERSION}" | circleci env subst)"
AWS_CLI_EVAL_INSTALL_DIR="$(eval echo "${AWS_CLI_EVAL_INSTALL_DIR}" | circleci env subst)"
AWS_CLI_EVAL_BINARY_DIR="$(eval echo "${AWS_CLI_EVAL_BINARY_DIR}" | circleci env subst)"

eval "$SCRIPT_UTILS"
detect_os
set_sudo

# Install per platform
if [ "$SYS_ENV_PLATFORM" = "linux" ] || [ "$SYS_ENV_PLATFORM" = "linux_alpine" ]; then
    eval "$SCRIPT_INSTALL_LINUX"
elif [ "$SYS_ENV_PLATFORM" = "windows" ]; then
    eval "$SCRIPT_INSTALL_WINDOWS"
elif [ "$SYS_ENV_PLATFORM" = "macos" ]; then
    eval "$SCRIPT_INSTALL_MACOS"
else
    echo "This orb does not currently support your platform. If you believe it should, please consider opening an issue on the GitHub repository:"
    echo "https://github.com/CircleCI-Public/aws-cli-orb/issues/new"
    exit 1
fi

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

if ! command -v aws >/dev/null 2>&1; then
    Install_AWS_CLI "${AWS_CLI_STR_AWS_CLI_VERSION}"
    Toggle_Pager
elif aws --version | grep "${AWS_CLI_STR_AWS_CLI_VERSION}"; then
    echo "AWS CLI version ${AWS_CLI_STR_AWS_CLI_VERSION} already installed. Skipping installation"
    exit 0
elif [ "$AWS_CLI_BOOL_OVERRIDE" -eq 1 ] || [ "${AWS_CLI_STR_AWS_CLI_VERSION}" != "latest" ]; then
    Uninstall_AWS_CLI
    Install_AWS_CLI "${AWS_CLI_STR_AWS_CLI_VERSION}"
    Toggle_Pager
else
    echo "AWS CLI is already installed, skipping installation."
    aws --version
fi
