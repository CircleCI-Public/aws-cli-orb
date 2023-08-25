#!/bin/sh
if grep "Alpine" /etc/issue >/dev/null 2>&1; then
    apk update
    apk --no-cache add \
        binutils \
        curl
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
    curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64$1.zip" -o "awscliv2.zip"

    echo "https://awscli.amazonaws.com/awscli-exe-linux-x86_64$1.zip"
    unzip awscliv2.zip
    aws/install
    rm -r awscliv2.zip ./aws 
else
    PLATFORM=$(uname -m)
    curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-$PLATFORM$1.zip" -o "awscliv2.zip"
    unzip -q -o awscliv2.zip
    $SUDO ./aws/install -i "${AWS_CLI_EVAL_INSTALL_DIR}" -b "${AWS_CLI_EVAL_BINARY_DIR}"
    rm -r awscliv2.zip ./aws
fi