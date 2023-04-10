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
  name                = "${var.resource_group_name}-${var.subnet_name}-zk-${count.index}"
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

### Brokers

resource "azurerm_public_ip" "broker_pip" {
  count                   = var.broker_count
  name                    = "${var.resource_group_name}-${var.subnet_name}-broker_pip-${count.index}"
  location                = data.azurerm_resource_group.resource_group.location 
  resource_group_name     = data.azurerm_resource_group.resource_group.name 
  allocation_method       = "Dynamic"
}

resource "azurerm_network_interface" "broker_nic" {
  count               = var.broker_count
  name                = "${var.resource_group_name}-${var.subnet_name}-broker_nic-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cluster_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.broker_pip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "broker" {
  count               = var.broker_count
  name                = "${var.resource_group_name}-${var.subnet_name}-broker-${count.index}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  size                = var.broker_vm_type
  admin_username      = var.user_name
  network_interface_ids = [
    azurerm_network_interface.broker_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.user_name
    public_key = file("${var.pub_key_path}")
  }

  os_disk {
    caching              = var.broker_disk_cache_policy
    storage_account_type = var.broker_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = "latest"
  }
}

### Schema Registry

resource "azurerm_public_ip" "sr_pip" {
  count                   = var.sr_count
  name                    = "${var.resource_group_name}-${var.subnet_name}-sr_pip-${count.index}"
  location                = data.azurerm_resource_group.resource_group.location 
  resource_group_name     = data.azurerm_resource_group.resource_group.name 
  allocation_method       = "Dynamic"
}

resource "azurerm_network_interface" "sr_nic" {
  count               = var.sr_count
  name                = "${var.resource_group_name}-${var.subnet_name}-sr_nic-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cluster_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sr_pip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "sr" {
  count               = var.sr_count
  name                = "${var.resource_group_name}-${var.subnet_name}-sr-${count.index}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  size                = var.sr_vm_type
  admin_username      = var.user_name
  network_interface_ids = [
    azurerm_network_interface.sr_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.user_name
    public_key = file("${var.pub_key_path}")
  }

  os_disk {
    caching              = var.sr_disk_cache_policy
    storage_account_type = var.sr_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = "latest"
  }
}

### Kafka Connect 

resource "azurerm_public_ip" "connect_pip" {
  count                   = var.connect_count
  name                    = "${var.resource_group_name}-${var.subnet_name}-connect_pip-${count.index}"
  location                = data.azurerm_resource_group.resource_group.location 
  resource_group_name     = data.azurerm_resource_group.resource_group.name 
  allocation_method       = "Dynamic"
}

resource "azurerm_network_interface" "connect_nic" {
  count               = var.connect_count
  name                = "${var.resource_group_name}-${var.subnet_name}-connect_nic-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cluster_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.connect_pip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "connect" {
  count               = var.connect_count
  name                = "${var.resource_group_name}-${var.subnet_name}-connect-${count.index}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  size                = var.connect_vm_type
  admin_username      = var.user_name
  network_interface_ids = [
    azurerm_network_interface.connect_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.user_name
    public_key = file("${var.pub_key_path}")
  }

  os_disk {
    caching              = var.connect_disk_cache_policy
    storage_account_type = var.connect_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = "latest"
  }
}

### Replicator 

resource "azurerm_public_ip" "replicator_pip" {
  count                   = var.replicator_count
  name                    = "${var.resource_group_name}-${var.subnet_name}-replicator_pip-${count.index}"
  location                = data.azurerm_resource_group.resource_group.location 
  resource_group_name     = data.azurerm_resource_group.resource_group.name 
  allocation_method       = "Dynamic"
}

resource "azurerm_network_interface" "replicator_nic" {
  count               = var.replicator_count
  name                = "${var.resource_group_name}-${var.subnet_name}-replicator_nic-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cluster_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.replicator_pip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "replicator" {
  count               = var.replicator_count
  name                = "${var.resource_group_name}-${var.subnet_name}-replicator-${count.index}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  size                = var.replicator_vm_type
  admin_username      = var.user_name
  network_interface_ids = [
    azurerm_network_interface.replicator_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.user_name
    public_key = file("${var.pub_key_path}")
  }

  os_disk {
    caching              = var.replicator_disk_cache_policy
    storage_account_type = var.replicator_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = "latest"
  }
}

### KSQL

resource "azurerm_public_ip" "ksql_pip" {
  count                   = var.ksql_count
  name                    = "${var.resource_group_name}-${var.subnet_name}-ksql_pip-${count.index}"
  location                = data.azurerm_resource_group.resource_group.location 
  resource_group_name     = data.azurerm_resource_group.resource_group.name 
  allocation_method       = "Dynamic"
}

resource "azurerm_network_interface" "ksql_nic" {
  count               = var.ksql_count
  name                = "${var.resource_group_name}-${var.subnet_name}-ksql_nic-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cluster_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ksql_pip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "ksql" {
  count               = var.ksql_count
  name                = "${var.resource_group_name}-${var.subnet_name}-ksql-${count.index}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  size                = var.ksql_vm_type
  admin_username      = var.user_name
  network_interface_ids = [
    azurerm_network_interface.ksql_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.user_name
    public_key = file("${var.pub_key_path}")
  }

  os_disk {
    caching              = var.ksql_disk_cache_policy
    storage_account_type = var.ksql_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = "latest"
  }
}

### Kafka Rest Proxy 

resource "azurerm_public_ip" "krp_pip" {
  count                   = var.krp_count
  name                    = "${var.resource_group_name}-${var.subnet_name}-krp_pip-${count.index}"
  location                = data.azurerm_resource_group.resource_group.location 
  resource_group_name     = data.azurerm_resource_group.resource_group.name 
  allocation_method       = "Dynamic"
}

resource "azurerm_network_interface" "krp_nic" {
  count               = var.krp_count
  name                = "${var.resource_group_name}-${var.subnet_name}-krp_nic-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cluster_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.krp_pip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "krp" {
  count               = var.krp_count
  name                = "${var.resource_group_name}-${var.subnet_name}-krp-${count.index}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  size                = var.krp_vm_type
  admin_username      = var.user_name
  network_interface_ids = [
    azurerm_network_interface.krp_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.user_name
    public_key = file("${var.pub_key_path}")
  }

  os_disk {
    caching              = var.krp_disk_cache_policy
    storage_account_type = var.krp_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = "latest"
  }
}

### Control Center 

resource "azurerm_public_ip" "c3_pip" {
  count                   = var.c3_count
  name                    = "${var.resource_group_name}-${var.subnet_name}-c3_pip-${count.index}"
  location                = data.azurerm_resource_group.resource_group.location 
  resource_group_name     = data.azurerm_resource_group.resource_group.name 
  allocation_method       = "Dynamic"
}

resource "azurerm_network_interface" "c3_nic" {
  count               = var.c3_count
  name                = "${var.resource_group_name}-${var.subnet_name}-c3_nic-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cluster_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.c3_pip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "c3" {
  count               = var.c3_count
  name                = "${var.resource_group_name}-${var.subnet_name}-c3-${count.index}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  size                = var.c3_vm_type
  admin_username      = var.user_name
  network_interface_ids = [
    azurerm_network_interface.c3_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.user_name
    public_key = file("${var.pub_key_path}")
  }

  os_disk {
    caching              = var.c3_disk_cache_policy
    storage_account_type = var.c3_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = "latest"
  }
}