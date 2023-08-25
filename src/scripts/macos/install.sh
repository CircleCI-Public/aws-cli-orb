#!/bin/sh
curl -sSL "https://awscli.amazonaws.com/AWSCLIV2$1.pkg" -o "AWSCLIV2.pkg"
$SUDO installer -pkg AWSCLIV2.pkg -target /
rm AWSCLIV2.pkg