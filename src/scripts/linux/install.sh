#!/bin/sh
#shellcheck disable=SC1090
Install_AWS_CLI() {
    if [ "$1" = "latest" ]; then
        version=""
    else
        version="-$1"
    fi

    echo "Installing AWS CLI v2"
    cd /tmp || exit
    if [ "$SYS_ENV_PLATFORM" = "linux_alpine" ]; then
        apk update && apk upgrade && apk add -U curl
        apk --no-cache add binutils 
        apk --no-cache add libcurl
        apk --no-cache upgrade libcurl
        curl -L https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub
        curl -LO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk
        curl -LO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-bin-2.34-r0.apk
        curl -LO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-i18n-2.34-r0.apk

        apk add --force-overwrite --no-cache \
            glibc-2.34-r0.apk \
            glibc-bin-2.34-r0.apk \
            glibc-i18n-2.34-r0.apk

        /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8
        curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64$version.zip" -o "awscliv2.zip"

        echo "https://awscli.amazonaws.com/awscli-exe-linux-x86_64$version.zip"
        unzip awscliv2.zip
        aws/install
        rm -r awscliv2.zip ./aws 
    else
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