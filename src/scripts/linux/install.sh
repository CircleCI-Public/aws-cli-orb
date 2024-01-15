#!/bin/sh
#shellcheck disable=SC1090
Install_AWS_CLI() {
    echo "Installing AWS CLI v2"
    cd /tmp || exit
    if [ "$SYS_ENV_PLATFORM" = "linux_alpine" ]; then
        apk update && apk upgrade && apk add -U curl
        apk --no-cache add binutils
        apk --no-cache add libcurl
        apk --no-cache upgrade libcurl
        apk --no-cache add aws-cli
    else
        if [ "$1" = "latest" ]; then
            version=""
        else
            version="-$1"
        fi

        PLATFORM=$(uname -m)
        curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-$PLATFORM$version.zip" -o "awscliv2.zip"
        unzip -q -o awscliv2.zip
        $SUDO ./aws/install -i "${AWS_CLI_EVAL_INSTALL_DIR}" -b "${AWS_CLI_EVAL_BINARY_DIR}"
        rm -r awscliv2.zip ./aws
    fi
}

Uninstall_AWS_CLI() {
    AWS_CLI_PATH=$(command -v aws)
    echo "$AWS_CLI_PATH"
    if [ -n "$AWS_CLI_PATH" ]; then
        EXISTING_AWS_VERSION=$(aws --version)
        echo "Uninstalling ${EXISTING_AWS_VERSION}"
        # shellcheck disable=SC2012
        if [ -L "$AWS_CLI_PATH" ]; then
            AWS_SYMLINK_PATH=$(ls -l "$AWS_CLI_PATH" | sed -e 's/.* -> //')
        fi
        $SUDO rm -rf "$AWS_CLI_PATH" "$AWS_SYMLINK_PATH" "$HOME/.aws/" "/usr/local/bin/aws" "/usr/local/bin/aws_completer" "/usr/local/aws-cli"
    else
        echo "No AWS install found"
    fi
}