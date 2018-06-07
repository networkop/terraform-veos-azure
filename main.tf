
# Create a Devices inside CVP
resource "cvp_device" "veos" {
    ip_address = "${module.veos.veos_public_ip}"
    container = "UBS"
    wait = "120"
    reconcile = true
    configlets = [{
        name = "${cvp_configlet.ipsec.name}"
        push = true
    }]
    depends_on = ["module.veos", "cvp_configlet.ipsec"]
}

data "template_file" "ipsec" {
    template = "${file("ipsec.tpl")}"

    vars {
        publicIP          = "${module.veos.veos_public_ip}"
        ipsec_psk         = "${var.ipsec_psk}"
        local_subnet_1    = "${module.veos.local_subnet_1}"
        inside_gw         = "${module.veos.inside_gw}"
        local_tunnel_ip   = "${var.tunnel_ip}"
        tunnel_source     = "${module.veos.tunnel_source}"
        tunnel_dest       = "${var.tunnel_dest}"
        local_asn         = "${var.local_asn}"
        local_community   = "${var.community}"
        peer_asn          = "${var.peer_asn}"
        peer_desc         = "${var.peer_desc}"
        peer_key          = "${var.peer_key}"
        peer_tunnel_ip    = "${var.peer_tunnel_ip}"
    }
} 

resource "cvp_configlet" "ipsec" {
    name   = "${module.veos.veos_public_ip}_IPSEC"
    config = "${data.template_file.ipsec.rendered}"
}


# Create a vEOS device in Azure
module "veos" {
    source = "./veos-azure"

    prefix                = "${var.prefix}"
    resource_group        = "${var.resource_group}"
    location              = "${var.location}"
    inside_sub            = "${var.inside_sub}"
    outside_sub           = "${var.outside_sub}"
    peer_subnet_1         = "${var.peer_subnet_1}"
    vnet_name             = "${var.vnet_name}"

    veos_license          = "${var.veos_license}"
    ipsec_license         = "${var.ipsec_license}"
    pub_ssh_key           = "${var.pub_ssh_key}"
    admin_username        = "${var.admin_username}"
    admin_password        = "${var.admin_password}"

    test_sub              = "${var.test_sub}"
}

