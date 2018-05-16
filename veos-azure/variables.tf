variable "prefix" {
  default = "AZURE-POC-SPOKE"
}

variable "resource_group" {
  default = "EMEA-MKASHIN"
}

variable "location" {
  default = "UK West"
}

variable "address_space" {
  default = "10.8.0.0/16"
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