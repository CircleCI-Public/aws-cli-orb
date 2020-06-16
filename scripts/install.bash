AWS_VER_REGEXP_2='aws-cli\/2.\d*.\d*'
AWS_VER_REGEXP_1='aws-cli\/2.\d*.\d*'
#initialize installed version to zero, to signify not installed.
AWS_CLI_INSTALLED_VERSION="0"
AWS_CLI_VERSION_SELECTED="<<parameters.version>>"

if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi

if ! command -v aws --version >/dev/null 2>&1  ; then
    echo AWS is not installed
else
    echo AWS is currently installed.
    if aws --version 2>&1 | grep -q $AWS_VER_REGEXP_2; then
        echo AWS CLI v2 is installed
        AWS_CLI_INSTALLED_VERSION="2"
    fi
    if aws --version 2>&1 | grep -q $AWS_VER_REGEXP_1; then
        echo AWS CLI v1 is installed
        AWS_CLI_INSTALLED_VERSION="1"
    fi
fi

#If the desired version of the CLI is not installed, install it.
if [[ $AWS_CLI_VERSION_SELECTED != $AWS_CLI_INSTALLED_VERSION ]]; then

    #uninstall AWS CLI if it is installed.
    if which aws; then
        echo Uninstalling old CLI
        $SUDO rm -rf /usr/local/aws
        $SUDO rm /usr/local/bin/aws
    fi

    case $AWS_CLI_VERSION_SELECTED in
        "1")
            # install CLI v1
            export PIP=$(which pip pip3 | head -1)
            if [[ -n $PIP ]]; then
                if which sudo > /dev/null; then
                    sudo $PIP install awscli --upgrade
                else
                    # This installs the AWS CLI to ~/.local/bin. Make sure that ~/.local/bin is in your $PATH.
                    $PIP install awscli --upgrade --user
                fi
            elif [[ $(which unzip curl | wc -l) -eq 2 ]]; then
                cd
                curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
                unzip awscli-bundle.zip
                if which sudo > /dev/null; then
                    sudo ~/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
                else
                    # This installs the AWS CLI to the default location (~/.local/lib/aws) and create a symbolic link (symlink) at ~/bin/aws. Make sure that ~/bin is in your $PATH.
                    awscli-bundle/install -b ~/bin/aws
                fi
                rm -rf awscli-bundle*
                cd -
            else
                echo "Unable to install AWS CLI. Please install pip."
                exit 1
            fi
            # Installation check
            if aws --version &> grep -q "aws-cli/1"; then
                echo "AWS CLI V1 has been installed successfully"
                exit 0
            else
                echo "There was an issue installing the AWS CLI V1. Exiting."
                exit 1
            fi
        ;;
        "2")
            # install CLI v2

            cd /tmp || exit

            # PLATFORM CHECK: mac vs. alpine vs. other linux
            if uname -a | grep Darwin; then
                SYS_ENV_PLATFORM=darwin
            elif uname -a | grep Linux; then
                SYS_ENV_PLATFORM=linux
            else
                echo "This platform appears to be unsupported."
                uname -a
                exit 1
            fi

            case $SYS_ENV_PLATFORM in
                linux)
                    curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip awscliv2.zip
                    $SUDO ./aws/install
                    rm awscliv2.zip
                    ;;
                darwin)
                    curl -sSL "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
                    $SUDO installer -pkg AWSCLIV2.pkg -target /
                    rm AWSCLIV2.pkg
                    ;;
                *)
                    echo "This orb does not currently support your platform. If you believe it should, please consider opening an issue on the GitHub repository:"
                    echo "https://github.com/CircleCI-Public/aws-cli-orb/issues/new"
                    exit 1
                ;;
            esac
            # Installation check
            if aws --version &> grep -q "aws-cli/2"; then
                echo "AWS CLI V2 has been installed successfully"
                exit 0
            else
                echo "There was an issue installing the AWS CLI V2. Exiting."
                exit 1
            fi
        ;;
    esac

else
    echo "The v${AWS_CLI_VERSION_SELECTED} AWS CLI is already installed."
    exit 0
fi