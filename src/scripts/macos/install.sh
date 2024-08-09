#!/bin/sh
Install_AWS_CLI() {
    if [ "$1" = "latest" ]; then
        version=""
    else
        version="$1"
    fi
    echo "Installing AWS CLI v2"
    cd /tmp || exit
    curl -o awscli.tar.gz "https://awscli.amazonaws.com/awscli-$version.tar.gz"
    tar -xzf awscli.tar.gz
    rm awscli.tar.gz
    cd "awscli-$version" || exit
    ./configure --with-download-deps
    make
    make install
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