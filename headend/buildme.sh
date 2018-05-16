#!/bin/bash

# Build CVP plugin
go build -o terraform.d/plugins/linux_amd64/terraform-provider-cvp github.com/networkop/terraform-cvp

# Create link to provider credentials
ln -s ../provider.tf provider.tf

# Initialise and apply configuration
terraform init
terraform apply -auto-approve -var-file="../secrets.tfvars"

