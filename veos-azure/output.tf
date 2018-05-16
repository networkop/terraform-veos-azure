
output "veos_public_ip" {
  value = "${azurerm_public_ip.main.ip_address}"
}

output "veos_username" {
  value = "${var.admin_username}"
}

output "veos_password" {
  value = "${var.admin_password}"
}

output "created_subnets" {
  value = ["${local.inside_subnet}", "${local.outside_subnet}", "${local.test_subnet}"]
}

output "test_vm_public_ip" {
  value = "${azurerm_public_ip.local_test.ip_address}"
}

output "local_subnet_1" {
  value = "${local.test_subnet}"
}

output "tunnel_source" {
  value = "${azurerm_network_interface.outside.private_ip_address}"
}

output "inside_gw" {
  value = "${local.inside_gateway}"
}