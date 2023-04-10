provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
}



resource "azurerm_subnet" "cluster_subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.subnet_addres_prefix]
}

### Zookeeper

resource "azurerm_network_interface" "zk_nic" {
  count               = var.zk_count
  name                = "${var.resource_group_name}-${var.subnet_name}-zk_nic-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cluster_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "zk" {
  count               = var.zk_count
  name                = "${var.resource_group_name}-zk-${count.index}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  size                = var.zk_vm_type
  admin_username      = var.user_name
  network_interface_ids = [
    azurerm_network_interface.zk_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.user_name
    public_key = file("${var.pub_key_path}")
  }

  os_disk {
    caching              = var.zk_disk_cache_policy
    storage_account_type = var.zk_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = "latest"
  }
}

