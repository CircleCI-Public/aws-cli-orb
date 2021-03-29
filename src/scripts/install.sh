if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi

if [ ! "$(which aws)" ] || [ "$PARAM_AWS_CLI_OVERRIDE" = 1 ]; then
    # setup
    if [ ! "$PARAM_AWS_CLI_VERSION" = "latest" ]; then export AWS_CLI_VER_STRING="-$PARAM_AWS_CLI_VERSION"; fi

    # Uninstall existing AWS CLI if override is enabled.
    if [ "$PARAM_AWS_CLI_OVERRIDE" = 1 ]; then
        AWS_CLI_PATH=$(which aws)
        if [ -n "$AWS_CLI_PATH" ]; then
            EXISTING_AWS_VERSION=$(aws --version)
            echo "Uninstalling ${EXISTING_AWS_VERSION}"
            # shellcheck disable=SC2012
            AWS_SYMLINK_PATH=$(ls -l "$AWS_CLI_PATH" | sed -e 's/.* -> //')
            $SUDO rm -rf "$AWS_CLI_PATH" "$AWS_SYMLINK_PATH" "$HOME/.aws/" "/usr/local/bin/aws" "/usr/local/bin/aws_completer" "/usr/local/aws-cli"
        else
            echo "No AWS install found"
        fi
    fi

    echo "Installing AWS CLI v2"
    # Platform check
    if uname -a | grep Darwin; then
        export SYS_ENV_PLATFORM=darwin
    elif uname -a | grep Linux; then
        export SYS_ENV_PLATFORM=linux
    elif uname -a | grep aarch64; then
        export SYS_ENV_PLATFORM=arm
    else
        echo "This platform appears to be unsupported."
        uname -a
        exit 1
    fi
    # Install per platform
    case $SYS_ENV_PLATFORM in
    linux)
        curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64${AWS_CLI_VER_STRING}.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        $SUDO ./aws/install
        rm awscliv2.zip
        ;;
    darwin)
        curl -sSL "https://awscli.amazonaws.com/AWSCLIV2${AWS_CLI_VER_STRING}.pkg" -o "AWSCLIV2.pkg"
        $SUDO installer -pkg AWSCLIV2.pkg -target /
        rm AWSCLIV2.pkg
        ;;
    arm)
        curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-aarch64${AWS_CLI_VER_STRING}.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        $SUDO ./aws/install
        rm awscliv2.zip
        ;;
    *)
        echo "This orb does not currently support your platform. If you believe it should, please consider opening an issue on the GitHub repository:"
        echo "https://github.com/CircleCI-Public/aws-cli-orb/issues/new"
        exit 1
    ;;
    esac
    # Toggle AWS Pager
    if [ "$PARAM_AWS_CLI_DISABLE_PAGER" = 1 ]; then
        if [ -z "${AWS_PAGER+x}" ]; then
            echo 'export AWS_PAGER=""' >> "$BASH_ENV"
            echo "AWS_PAGER is being set to the empty string to disable all output paging for AWS CLI commands."
            echo "You can set the 'disable-aws-pager' parameter to 'false' to disable this behavior."
        fi
    fi
else
    echo "AWS CLI is already installed, skipping isntallation."
    aws --version
fi