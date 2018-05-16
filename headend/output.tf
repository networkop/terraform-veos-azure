
output "veos_public_ip" {
  value = "${data.azurerm_public_ip.main.ip_address}"
}

output "veos_username" {
  value = "${var.admin_username}"
}

output "veos_password" {
  value = "${var.admin_password}"
}

output "tunnel_ip" {
  value = "${var.tunnel_ip}"
}

output "created_subnets" {
  value = ["${local.inside_subnet}", "${local.outside_subnet}", "${local.test_subnet}"]
}

output "test_vm_public_ip" {
  value = "${azurerm_public_ip.local_test.ip_address}"
}
