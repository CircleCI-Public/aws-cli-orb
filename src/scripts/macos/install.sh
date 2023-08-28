#!/bin/sh
Install_AWS_CLI() {
    if [ "$1" = "latest" ]; then
        version=""
    else
        version="-$1"
    fi
    echo "Installing AWS CLI v2"
    cd /tmp || exit
    curl -sSL "https://awscli.amazonaws.com/AWSCLIV2$version.pkg" -o "AWSCLIV2.pkg"
    $SUDO installer -pkg AWSCLIV2.pkg -target /
    rm AWSCLIV2.pkg
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
        if uname -a | grep "x86_64 Msys"; then export SUDO=""; fi
        $SUDO rm -rf "$AWS_CLI_PATH" "$AWS_SYMLINK_PATH" "$HOME/.aws/" "/usr/local/bin/aws" "/usr/local/bin/aws_completer" "/usr/local/aws-cli"
    else
        echo "No AWS install found"
    fi
}