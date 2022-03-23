if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi

Install_AWS_CLI (){
    echo "Installing AWS CLI v2"
    cd /tmp || exit
    # Platform check
    if uname -a | grep "Darwin"; then
        export SYS_ENV_PLATFORM=macos
    elif uname -a | grep "x86_64 GNU/Linux"; then
        export SYS_ENV_PLATFORM=linux_x86
    elif uname -a | grep "aarch64 GNU/Linux"; then
        export SYS_ENV_PLATFORM=linux_arm
    elif uname -a | grep "x86_64 Msys"; then
        export SYS_ENV_PLATFORM=windows
    elif cat /etc/issue | grep "Alpine" > /dev/null 2>&1; then
        export SYS_ENV_PLATFORM=linux_alpine
    else
        echo "This platform appears to be unsupported."
        uname -a
        exit 1
    fi
    echo "Platform $SYS_ENV_PLATFORM"
    # Install per platform
    case $SYS_ENV_PLATFORM in
    linux_x86)
        curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64$1.zip" -o "awscliv2.zip"
        unzip -q -o awscliv2.zip
        $SUDO ./aws/install
        rm awscliv2.zip
        ;;
    windows)
        curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64$1.zip" -o "awscliv2.zip"
        unzip -q -o awscliv2.zip
        ./aws/install
        rm awscliv2.zip
        ;;
    macos)
        curl -sSL "https://awscli.amazonaws.com/AWSCLIV2$1.pkg" -o "AWSCLIV2.pkg"
        $SUDO installer -pkg AWSCLIV2.pkg -target /
        rm AWSCLIV2.pkg
        ;;
    linux_arm)
        curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-aarch64$1.zip" -o "awscliv2.zip"
        unzip -q -o awscliv2.zip
        $SUDO ./aws/install
        rm awscliv2.zip
        ;;
    linux_alpine)
        apk --no-cache add \
        binutils \
        curl \

        curl -L https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub 
        curl -LO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk 
        curl -LO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-bin-2.34-r0.apk 
        curl -LO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-i18n-2.34-r0.apk 

        apk add --no-cache \
        glibc-2.34-r0.apk \
        glibc-bin-2.34-r0.apk \
        glibc-i18n-2.34-r0.apk \

        /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 
        curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64$1.zip" -o "awscliv2.zip"

        unzip awscliv2.zip 
        aws/install 
        rm awscliv2.zip
        ;;
    *)
        echo "This orb does not currently support your platform. If you believe it should, please consider opening an issue on the GitHub repository:"
        echo "https://github.com/CircleCI-Public/aws-cli-orb/issues/new"
        exit 1
    ;;
    esac
}

export AWS_CLI_VER_STRING=""
if [ ! "$PARAM_AWS_CLI_VERSION" = "latest" ]; then export AWS_CLI_VER_STRING="-$PARAM_AWS_CLI_VERSION"; fi

# If aws is not installed
if [ ! "$(command -v aws)" ]; then
    Install_AWS_CLI "${AWS_CLI_VER_STRING}"
fi


















