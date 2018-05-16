variable "prefix" {
  description = "String to prepend in front of every new created object"
}
variable "resource_group" {
  description = "Existing resource group inside Azure"
}
variable "location" {
  description = "Desired location for objects and their metadata"
}
variable "address_space" {
  description = "RFC1918 prefix to be assigned to VNET"
}

variable "vm_size" {
  description = "vEOS VM size"
  default = "Standard_F2"
}

variable "admin_username" {
  description = "Admin username configured on vEOS and test VMs"
}
variable "admin_password" {
  description = "Admin password"
}
variable "pub_ssh_key" {
  description = "Public ssh key (contents of ~/.ssh/id_rsa.pub) for passwordless login"
}
variable "ipsec_psk" {
  description = "IPsec pre-shared key"
}
variable "local_asn" {
  description = "Local-side BGP ASN"
}
variable "community" {
  description = "Second part of community value, e.g. <BGP_ASN>:<This value>"
}
variable "peer_tunnel_ip" {
  description = "Tunnel IP address of a remote peer"
}
variable "peer_asn" {
  description = "Peer BGP ASN"
}

variable "peer_desc" {
  description = "BGP neighbor description"
  default = "POC peer"
}
variable "peer_key" {
  description = "BGP neighbor password"
}
variable "peer_subnet_1" {
  description = "Subnet advertised from remote peer (used to setup static routes for Azure subnets)"
}
variable "tunnel_ip" {
  description = "Local-side tunnel prefix, e.g. 169.254.0.10/24"
}
variable "tunnel_dest" {
  description = "Remote tunnel destination public IP address"
}
variable "ipsec_license" {
  description = "vEOS IPsec license URL"
}
variable "veos_license" {
  description = "vEOS license URL"
}
variable "veos_image" {
  description = "vEOS Image details"
  type = "map"
  default = {
      publisher = "arista-networks"
      offer     = "veos-router"
      sku       = "eos-4_20_1fx-virtual-router"
      version   = "latest"
  }
}