variable "prefix" {}
variable "resource_group" {}
variable "location" {}
variable "address_space" {}

variable "vm_size" {
  default = "Standard_F2"
}

variable "admin_username" {}
variable "admin_password" {}
variable "pub_ssh_key" {}
variable "ipsec_psk" {}
variable "local_asn" {}
variable "community" {}
variable "peer_tunnel_ip" {}
variable "peer_asn" {}

variable "peer_desc" {
  default = "POC peer"
}
variable "peer_key" {}
variable "peer_subnet_1" {}
variable "tunnel_ip" {}
variable "tunnel_dest" {}
variable "ipsec_license" {}
variable "veos_license" {}
variable "veos_image" {
    type = "map"
    default = {
        publisher = "arista-networks"
        offer     = "veos-router"
        sku       = "eos-4_20_1fx-virtual-router"
        version   = "latest"
    }

}