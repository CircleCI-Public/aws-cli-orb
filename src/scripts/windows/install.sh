#!/bin/sh
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
