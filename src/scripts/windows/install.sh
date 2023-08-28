#!/bin/sh

Install_AWS_CLI(){
    echo "Installing AWS CLI v2"
    cd /tmp || exit
    
    if [ ! "$(command -v choco)" ]; then
        echo "Chocolatey is required to uninstall AWS"
        exit 1
    fi
    choco install awscli --version="$1"
    echo "$1"
    if echo "$1" | grep "2."; then
        echo "export PATH=\"\${PATH}:/c/Program Files/Amazon/AWSCLIV2\"" >> "$BASH_ENV"

    else
        echo "export PATH=\"\${PATH}:/c/Program Files/Amazon/AWSCLI/bin\"" >>"$BASH_ENV"
    fi
        # Toggle AWS Pager
    if [ "$AWS_CLI_BOOL_DISABLE_PAGER" -eq 1 ]; then
        if [ -z "${AWS_PAGER+x}" ]; then
            echo 'export AWS_PAGER=""' >>"$BASH_ENV"
            echo "AWS_PAGER is being set to the empty string to disable all output paging for AWS CLI commands."
            echo "You can set the 'disable-aws-pager' parameter to 'false' to disable this behavior."
        fi
    fi
}


Uninstall_AWS_CLI() {
    if [ ! "$(command -v choco)" ]; then
        echo "Chocolatey is required to uninstall AWS"
        exit 1
    fi
    choco uninstall awscli
}