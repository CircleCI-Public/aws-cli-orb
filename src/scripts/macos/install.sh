#!/bin/sh
Install_AWS_CLI() {
    echo "Installing AWS CLI v$1"
    if [ "$USE_BREW" -eq 1 ]; then
        HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ASK=1 brew install "awscli"
    else
        if [ "$1" = "latest" ]; then
            pkg_url="https://awscli.amazonaws.com/AWSCLIV2.pkg"
        else
            pkg_url="https://awscli.amazonaws.com/AWSCLIV2-$1.pkg"
        fi
        curl -o /tmp/AWSCLIV2.pkg "$pkg_url"
        $SUDO installer -pkg /tmp/AWSCLIV2.pkg -target /
        rm /tmp/AWSCLIV2.pkg
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