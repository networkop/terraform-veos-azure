#!/bin/bash
terraform init
terraform apply -auto-approve -var-file="../secrets.tfvars"

