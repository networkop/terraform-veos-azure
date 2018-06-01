#!/bin/bash
go get -u github.com/networkcop/cvpgo
go get -u github.com/networkcop/terraform-cvp
go build -o terraform.d/plugins/linux_amd64/terraform-provider-cvp github.com/networkop/terraform-cvp
