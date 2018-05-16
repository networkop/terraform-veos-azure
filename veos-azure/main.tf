
# Creating a VM inside Azure 


# Computing local variables 
locals {
  virtual_machine_name = "${var.prefix}-VEOS"
  outside_netmask      = "${cidrnetmask(local.outside_subnet)}"
  outside_gateway      = "${cidrhost(local.outside_subnet, 1)}"
  inside_netmask       = "${cidrnetmask(local.inside_subnet)}"
  inside_gateway       = "${cidrhost(local.inside_subnet, 1)}"
  outside_subnet       = "${cidrsubnet(var.address_space, 8, 0)}"
  inside_subnet        = "${cidrsubnet(var.address_space, 8, 1)}"
  test_subnet          = "${cidrsubnet(var.address_space, 8, 2)}"
}

# Create custom userdata
data "template_file" "init" {
    template = "${file("init.tpl")}"

    vars {
        # User-defined variables
        username          = "${var.admin_username}"
        password          = "${var.admin_password}"

        # Computed variables
        hostname          = "${local.virtual_machine_name}"
        publicIP          = "${data.azurerm_public_ip.main.ip_address}"
        outside_ip        = "${data.azurerm_network_interface.outside.private_ip_address}"
        outside_netmask   = "${local.outside_netmask}"
        inside_ip         = "${data.azurerm_network_interface.inside.private_ip_address}"
        inside_netmask    = "${local.inside_netmask}"
        outside_gw        = "${local.outside_gateway}"

    }
} 

# The below is commented out because we're assuming that RG object already exists
 
## Create a Resource Group for the new Virtual Machine.
#resource "azurerm_resource_group" "main" {
#  name     = "${var.resource_group}"
#  location = "${var.location}"
#}


# Create a Virtual Network within the Resource Group
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-VNET"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${var.resource_group}"
  location            = "${var.location}"
}


# Create an Outside Subnet within the Virtual Network
resource "azurerm_subnet" "outside" {
  name                 = "${var.prefix}-VSUB-OUTSIDE"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = "${var.resource_group}"
  address_prefix       = "${local.outside_subnet}"
}


# Create an Inside subnet within the Virtual Network
resource "azurerm_subnet" "inside" {
  name                 = "${var.prefix}-VSUB-INSIDE"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = "${var.resource_group}"
  address_prefix       = "${local.inside_subnet}"
}


# Create a Public IP for the Virtual Machine
resource "azurerm_public_ip" "main" {
  name                         = "${var.prefix}-PIP"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group}"
  public_ip_address_allocation = "Static"
}

# Creating data to extract Public IP later on
data "azurerm_public_ip" "main" {
  name                = "${var.prefix}-PIP"
  resource_group_name = "${var.resource_group}"
  depends_on          = ["azurerm_public_ip.main"]
}

# Create a Network Security Group with some rules
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-NSG"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_HTTPS"
    description                = "Allow HTTPs access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create an "Outside" NIC for VMs and attach the PIP and the NSG
resource "azurerm_network_interface" "outside" {
  name                      = "${var.prefix}-OUTSIDE"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  enable_ip_forwarding      = true
  
  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.outside.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.main.id}"
    primary                       = true
  }
}

data "azurerm_network_interface" "outside" {
    name                = "${var.prefix}-OUTSIDE"
    resource_group_name = "${var.resource_group}"
    depends_on          = ["azurerm_network_interface.outside"]
}

# Create an "Inside" NIC for VMs and attach the PIP and the NSG
resource "azurerm_network_interface" "inside" {
  name                      = "${var.prefix}-INSIDE"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group}"

  enable_ip_forwarding      = true
  
  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.inside.id}"
    private_ip_address_allocation = "dynamic"
  }
}

data "azurerm_network_interface" "inside" {
  name                = "${var.prefix}-INSIDE"
  resource_group_name = "${var.resource_group}"
  depends_on          = ["azurerm_network_interface.inside"]
}


# Create a new Virtual Machine based on the vEOS Image
resource "azurerm_virtual_machine" "veos" {
  name                             = "${local.virtual_machine_name}"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group}"
  network_interface_ids            = ["${azurerm_network_interface.outside.id}", "${azurerm_network_interface.inside.id}"]
  primary_network_interface_id     = "${azurerm_network_interface.outside.id}"
  vm_size                          = "${var.vm_size}" #"Standard_F2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher   = "${lookup(var.veos_image,"publisher")}"
    offer       = "${lookup(var.veos_image,"offer")}"
    sku         = "${lookup(var.veos_image,"sku")}"
    version     = "${lookup(var.veos_image,"version")}"
  }

  plan {
    publisher   = "${lookup(var.veos_image,"publisher")}"
    name        = "${lookup(var.veos_image,"sku")}"
    product     = "${lookup(var.veos_image,"offer")}"
  }

  storage_os_disk {
    name              = "${var.prefix}-OSDISK"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }


  os_profile {
    computer_name  = "${local.virtual_machine_name}"
    custom_data    = "${data.template_file.init.rendered}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${var.pub_ssh_key}"
      }
  }

  provisioner "remote-exec" {
    inline = [
      "FastCli -p 15 -c \"license import ${var.veos_license}\"",
      "FastCli -p 15 -c \"license import ${var.ipsec_license}\"",
    ]
    connection {
    type     = "ssh"
    host     = "${data.azurerm_public_ip.main.ip_address}"
    user     = "root"
    password = "${var.admin_password}"
  }
  }
}

/*
  Block below is optional.
  It creates a test subnet and a redirects traffic from it via vEOS 
*/

# Create UDR to redirect local subnet via vEOS
resource "azurerm_route_table" "rt_1" {
  name                 = "${var.prefix}-RT-1"
  resource_group_name  = "${var.resource_group}"
  location             = "${var.location}"

  route  {
    name                   = "${var.prefix}-ROUTE-1"
    address_prefix         = "${var.peer_subnet_1}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${data.azurerm_network_interface.inside.private_ip_address}"
  }

}

# Create a test subnet with UDR
resource "azurerm_subnet" "local_test" {
  name                 = "${var.prefix}-VSUB-TEST"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = "${var.resource_group}"
  address_prefix       = "${local.test_subnet}"

  route_table_id       = "${azurerm_route_table.rt_1.id}"

}

resource "azurerm_public_ip" "local_test" {
  name                         = "${var.prefix}-PIP-TEST"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "local_test" {
  name                = "${var.prefix}-VNIC-TEST"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.local_test.id}"
    public_ip_address_id          = "${azurerm_public_ip.local_test.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_managed_disk" "local_test" {
  name                 = "${var.prefix}-DISK-TEST"
  location             = "${var.location}"
  resource_group_name  = "${var.resource_group}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_virtual_machine" "local_test" {
  name                  = "${var.prefix}-VM-TEST"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group}"
  network_interface_ids = ["${azurerm_network_interface.local_test.id}"]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-OS-DISK-TEST"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${azurerm_virtual_network.main.name}-VM-TEST"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${var.pub_ssh_key}"
      }
  }

}