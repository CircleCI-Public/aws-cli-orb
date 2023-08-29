#!/bin/sh

Install_AWS_CLI(){
    if [ "$1" = "latest" ]; then
        version=""
    else
        version="$1"
    fi
    echo "Installing AWS CLI v2"
    cd /tmp || exit
    
    if ! command -v choco >/dev/null 2>&1; then
        echo "Chocolatey is required to install AWS"
        exit 1
    fi
    
    choco install awscli --version="$version"
    echo "Installing AWS CLI version $version"
    if echo "$1" | grep "2."; then
        echo "export PATH=\"\${PATH}:/c/Program Files/Amazon/AWSCLIV2\"" >> "$BASH_ENV"
    else
        echo "export PATH=\"\${PATH}:/c/Program Files/Amazon/AWSCLI/bin\"" >>"$BASH_ENV"
    fi
}

Uninstall_AWS_CLI() {
    if ! command -v choco >/dev/null 2>&1; then
        echo "Chocolatey is required to uninstall AWS"
        exit 1
    fi
    choco uninstall awscli
}