#!/bin/bash
set -e
set -o pipefail

echo ========================================
echo Getting Creds from Doormat
echo ========================================

# AWS
doormat login -v || doormat login && eval $(doormat aws export --account aws_guy_test)

# Azure
# Not needed, as we can use the CLI creds


echo
echo ========================================
echo Building image ${HCP_PACKER_BUILD_FINGERPRINT}
echo ========================================
packer init .
packer build  .



echo
echo ========================================
echo Updating HCP Packer Done
echo ========================================

# This is where you'd do validation before promoting...
