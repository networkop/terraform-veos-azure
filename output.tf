
output "veos_public_ip" {
  value = "${module.veos.veos_public_ip}"
}

output "veos_username" {
  value = "${module.veos.veos_username}"
}

output "veos_password" {
  value = "${module.veos.veos_password}"
}

output "tunnel_ip" {
  value = "${var.tunnel_ip}"
}

output "created_subnets" {
  value = "${module.veos.created_subnets}"
}

output "test_vm_public_ip" {
  value = "${module.veos.test_vm_public_ip}"
}

output "local_subnet_1" {
  value = "${module.veos.local_subnet_1}"
}

output "tunnel_source" {
  value = "${module.veos.tunnel_source}"
}

output "inside_gw" {
  value = "${module.veos.inside_gw}"
}
