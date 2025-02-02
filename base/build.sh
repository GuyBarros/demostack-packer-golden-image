#!/bin/bash
set -e
set -o pipefail

echo ========================================
echo Getting Creds from Doormat
echo ========================================

# AWS
doormat login -v || doormat login && eval $(doormat aws export --account aws_lucy.davinhart_test)

# Azure
# Not needed, as we can use the CLI creds


echo
echo ========================================
echo Building image ${HCP_PACKER_BUILD_FINGERPRINT}
echo ========================================
packer init .
packer build -force .



echo
echo ========================================
echo Updating HCP Packer Channel
echo ========================================

# This is where you'd do validation before promoting...



# Get iteration ID from `latest` channel, and set to Prod
iteration_id=$(par channels get-iteration base-image latest)

par channels set-iteration base-image production ${iteration_id}
