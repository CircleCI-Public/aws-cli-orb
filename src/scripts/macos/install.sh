#!/bin/sh
Install_AWS_CLI() {
    echo "Installing AWS CLI v$version"
    if [ "$USE_BREW" -eq 1 ]; then
        brew install "awscli"
    else
        if [ "$1" = "latest" ]; then
            version=""
        else
            version="-$1"
        fi
        cd /tmp || exit
        curl -o awscli.tar.gz "https://awscli.amazonaws.com/awscli$version.tar.gz"
        mkdir awscli
        tar -xzf awscli.tar.gz -C awscli --strip-components=1
        rm awscli.tar.gz
        cd awscli || exit
        ./configure --with-download-deps
        make
        $SUDO make install
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