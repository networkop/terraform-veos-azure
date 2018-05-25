variable "prefix" {
  default = "AZURE-POC-SPOKE"
}

variable "resource_group" {
  default = "EMEA-MKASHIN"
}

variable "location" {
  default = "UK West"
}

variable "vnet_name" {
  default = "TEST-VNET"
}

variable "inside_sub" {
  default = "10.8.5.0/24"
}

variable "outside_sub" {
  default = "10.8.6.0/24"
}

variable "test_sub" {
  default = "10.8.99.0/24"
}

variable "vm_size" {
  default = "Standard_F2"
}

variable "admin_username" {}

variable "admin_password" {}

variable "pub_ssh_key" {}

variable "veos_license" {}

variable "ipsec_license" {}

variable "peer_subnet_1" {}

variable "veos_image" {
    type = "map"
    default = {
        publisher = "arista-networks"
        offer     = "veos-router"
        sku       = "eos-4_20_1fx-virtual-router"
        version   = "latest"
    }

}