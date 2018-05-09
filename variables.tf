variable "prefix" {
    default = "AZURE-POC-"
}

variable "resource_group" {
    default = "EMEA-MKASHIN"
}

variable "location" {
  default = "UK South"
}

variable "vnet" {
    default = "EMEA-MKASHIN-VNET-1"
}

variable "vm_size" {
    default = "Standard_F2"
}

variable "admin_username" {
  default = "cvpadmin"
}

variable "admin_password" {
  default = "AristaAdmin12345"
}

variable "veos_image" {
    type = "map"
    default = {
        publisher = "arista-networks"
        offer     = "veos-router"
        sku       = "eos-4_20_1fx-virtual-router"
        version   = "latest"
    }

}