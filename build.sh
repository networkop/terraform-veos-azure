#!/bin/bash
go get -u github.com/networkop/cvpgo
go get -u github.com/networkop/terraform-cvp
go build -o terraform.d/plugins/linux_amd64/terraform-provider-cvp github.com/networkop/terraform-cvp

go build -o terraform.d/plugins/windows_amd64/terraform-provider-cvp.exe github.com/networkop/terraform-cvp