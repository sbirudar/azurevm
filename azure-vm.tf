variable "prefix" {
  default = "groupc"
}

resource "azurerm_resource_group" "azure_rg" {
  name     = "${var.prefix}-resources"
  location = "Central US"
}

resource "azurerm_virtual_network" "azure_vnet" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.azure_rg.location}"
  resource_group_name = "${azurerm_resource_group.azure_rg.name}"
}

resource "azurerm_subnet" "azure_subnet" {
  name                 = "subnet"
  resource_group_name  = "${azurerm_resource_group.azure_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.azure_vnet.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_network_interface" "azure_nic" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.azure_rg.location}"
  resource_group_name = "${azurerm_resource_group.azure_rg.name}"

  ip_configuration {
    name                          = "groupc-vm-ip"
    subnet_id                     = "${azurerm_subnet.azure_subnet.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "azure_vm" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.azure_rg.location}"
  resource_group_name   = "${azurerm_resource_group.azure_rg.name}"
  network_interface_ids = ["${azurerm_network_interface.azure_nic.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "azure-groupc"
  }
}
