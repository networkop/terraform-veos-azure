

# Creating Devices inside CVP
# Implicit reference means it'll be done last
resource "cvp_device" "Device-A" {
    ip_address = "${data.azurerm_public_ip.main.ip_address}"
    depends_on = ["azurerm_virtual_machine.veos-1"]
}

# Creating a VM inside Azure 

locals {
  virtual_machine_name = "${var.prefix}vm"
}

# Create custom userdata
data "template_file" "init" {
    template = "${file("init.tpl")}"

    vars {
        publicIP = "${data.azurerm_public_ip.main.ip_address}"
        username = "${var.admin_username}"
        password = "${var.admin_username}"
        hostname = "${local.virtual_machine_name}"
    }
} 

## Create a Resource Group for the new Virtual Machine.
#resource "azurerm_resource_group" "main" {
#  name     = "${var.resource_group}"
#  location = "${var.location}"
#}
#
## Create a Virtual Network within the Resource Group
#resource "azurerm_virtual_network" "main" {
#  name                = "${var.resource_group}-VNET-1"
#  address_space       = ["10.7.0.0/16"]
#  resource_group_name = "${azurerm_resource_group.main.name}"
#  location            = "${azurerm_resource_group.main.location}"
#}

# Create a Subnet within the Virtual Network
resource "azurerm_subnet" "internal" {
  name                 = "${var.resource_group}-VNET-1-VSUB-0"
  virtual_network_name = "${var.vnet}"
  resource_group_name  = "${var.resource_group}"
  address_prefix       = "10.7.0.0/24"
}

# Create a Public IP for the Virtual Machine
resource "azurerm_public_ip" "main" {
  name                         = "${var.prefix}-pip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group}"
  public_ip_address_allocation = "Static"
}

data "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip"
  resource_group_name = "${var.resource_group}"
  depends_on          = ["azurerm_public_ip.main"]
}

# Create a Network Security Group with some rules
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
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

# Create a network interface for VMs and attach the PIP and the NSG
resource "azurerm_network_interface" "main" {
  name                      = "${var.prefix}-nic"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.main.id}"
  }
}

# Create a new Virtual Machine based on the Golden Image
resource "azurerm_virtual_machine" "veos-1" {
  name                             = "${local.virtual_machine_name}"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group}"
  network_interface_ids            = ["${azurerm_network_interface.main.id}"]
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
    name              = "${local.virtual_machine_name}-osdisk"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }


  os_profile {
    computer_name  = "${local.virtual_machine_name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    custom_data    = "${data.template_file.init.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}
