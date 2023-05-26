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

data "azurerm_dns_zone" "dns_zone" {
  name                = "a51245098a7f4871a33b.eastus.aksapp.io"
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

locals {
  zk_data_disks = flatten([
    for zk in range(0, var.zk_count) : [
      for disk in range(0, var.zk_data_disk_count) : {
        zk_index           = zk
        zk_data_disk_index = "${zk}${disk}"
      }
    ]
  ])

  zk_log_disks = flatten([
    for zk in range(0, var.zk_count) : [
      for disk in range(0, var.zk_log_disk_count) : {
        zk_index          = zk
        zk_log_disk_index = "${zk}${disk}"
      }
    ]
  ])

  broker_log_disks = flatten([
    for broker in range(0, var.broker_count) : [
      for disk in range(0, var.broker_log_disk_count) : {
        broker_index          = broker
        broker_log_disk_index = "${broker}${disk}"
      }
    ]
  ])
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
  tags = {
    owner_email = var.owner_email_tag
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
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = "latest"
  }
  tags = {
    owner_email = var.owner_email_tag
  }
}

resource "azurerm_managed_disk" "zk_data_disk" {
  for_each             = { for zk_data_disk_values in local.zk_data_disks : zk_data_disk_values.zk_data_disk_index => zk_data_disk_values }
  name                 = "${var.resource_group_name}-${var.subnet_name}-zk-datadisk-${each.value.zk_data_disk_index}"
  location             = data.azurerm_resource_group.resource_group.location
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  storage_account_type = var.zk_data_disk_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.zk_data_disk_size
  tags = {
    owner_email = var.owner_email_tag
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "zk_data_disk_attachment" {
  for_each           = { for zk_data_disk_values in local.zk_data_disks : zk_data_disk_values.zk_data_disk_index => zk_data_disk_values }
  managed_disk_id    = azurerm_managed_disk.zk_data_disk[each.value.zk_data_disk_index].id
  virtual_machine_id = azurerm_linux_virtual_machine.zk[each.value.zk_index].id
  lun                = each.value.zk_data_disk_index
  caching            = var.zk_data_disk_cache_policy
}

resource "azurerm_managed_disk" "zk_log_disk" {
  for_each             = { for zk_log_disk_values in local.zk_log_disks : zk_log_disk_values.zk_log_disk_index => zk_log_disk_values }
  name                 = "${var.resource_group_name}-${var.subnet_name}-zk-logdisk-${each.value.zk_log_disk_index}"
  location             = data.azurerm_resource_group.resource_group.location
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  storage_account_type = var.zk_log_disk_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.zk_log_disk_size
  tags = {
    owner_email = var.owner_email_tag
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "zk_log_disk_attachment" {
  for_each           = { for zk_log_disk_values in local.zk_log_disks : zk_log_disk_values.zk_log_disk_index => zk_log_disk_values }
  managed_disk_id    = azurerm_managed_disk.zk_log_disk[each.value.zk_log_disk_index].id
  virtual_machine_id = azurerm_linux_virtual_machine.zk[each.value.zk_index].id
  lun                = each.value.zk_log_disk_index + 10
  caching            = var.zk_log_disk_cache_policy
}

### Brokers

resource "azurerm_public_ip" "broker_pip" {
  count               = var.broker_count
  name                = "${var.resource_group_name}-${var.subnet_name}-broker_pip-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.resource_group_name}-${var.subnet_name}-broker-${count.index}"
  tags = {
    owner_email = var.owner_email_tag
  }
}

resource "azurerm_dns_cname_record" "public_dns_broker_record" {
  count               = var.broker_count
  name                = "${var.resource_group_name}-${var.subnet_name}-broker_record-${count.index}"
  zone_name           = data.azurerm_dns_zone.dns_zone.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  ttl                 = "300"
  record              = azurerm_public_ip.broker_pip[count.index].fqdn
  tags = {
    owner_email = var.owner_email_tag
  }
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
  tags = {
    owner_email = var.owner_email_tag
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
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = "latest"
  }

  tags = {
    owner_email = var.owner_email_tag
  }
}

resource "azurerm_managed_disk" "broker_log_disk" {
  for_each             = { for broker_log_disk_values in local.broker_log_disks : broker_log_disk_values.broker_log_disk_index => broker_log_disk_values }
  name                 = "${var.resource_group_name}-${var.subnet_name}-broker-logdisk-${each.value.broker_log_disk_index}"
  location             = data.azurerm_resource_group.resource_group.location
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  storage_account_type = var.broker_log_disk_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.broker_log_disk_size
  tags = {
    owner_email = var.owner_email_tag
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "broker_log_disk_attachment" {
  for_each           = { for broker_log_disk_values in local.broker_log_disks : broker_log_disk_values.broker_log_disk_index => broker_log_disk_values }
  managed_disk_id    = azurerm_managed_disk.broker_log_disk[each.value.broker_log_disk_index].id
  virtual_machine_id = azurerm_linux_virtual_machine.broker[each.value.broker_index].id
  lun                = each.value.broker_log_disk_index + 20
  caching            = var.broker_log_disk_cache_policy
}

### Schema Registry

resource "azurerm_public_ip" "sr_pip" {
  count               = var.sr_count
  name                = "${var.resource_group_name}-${var.subnet_name}-sr_pip-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.resource_group_name}-${var.subnet_name}-sr-${count.index}"
  tags = {
    owner_email = var.owner_email_tag
  }
}

resource "azurerm_dns_cname_record" "public_dns_sr_record" {
  count               = var.sr_count
  name                = "${var.resource_group_name}-${var.subnet_name}-sr_record-${count.index}"
  zone_name           = data.azurerm_dns_zone.dns_zone.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  ttl                 = "300"
  record              = azurerm_public_ip.sr_pip[count.index].fqdn
  tags = {
    owner_email = var.owner_email_tag
  }
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
  tags = {
    owner_email = var.owner_email_tag
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

  tags = {
    owner_email = var.owner_email_tag
  }
}

### Kafka Connect 

resource "azurerm_public_ip" "connect_pip" {
  count               = var.connect_count
  name                = "${var.resource_group_name}-${var.subnet_name}-connect_pip-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.resource_group_name}-${var.subnet_name}-connect-${count.index}"
  tags = {
    owner_email = var.owner_email_tag
  }
}

resource "azurerm_dns_cname_record" "public_dns_connect_record" {
  count               = var.connect_count
  name                = "${var.resource_group_name}-${var.subnet_name}-connect_record-${count.index}"
  zone_name           = data.azurerm_dns_zone.dns_zone.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  ttl                 = "300"
  record              = azurerm_public_ip.connect_pip[count.index].fqdn
  tags = {
    owner_email = var.owner_email_tag
  }
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
  tags = {
    owner_email = var.owner_email_tag
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

  tags = {
    owner_email = var.owner_email_tag
  }
}

### Replicator 

resource "azurerm_public_ip" "replicator_pip" {
  count               = var.replicator_count
  name                = "${var.resource_group_name}-${var.subnet_name}-replicator_pip-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"
  tags = {
    owner_email = var.owner_email_tag
  }
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
  tags = {
    owner_email = var.owner_email_tag
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
  count               = var.ksql_count
  name                = "${var.resource_group_name}-${var.subnet_name}-ksql_pip-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"
  tags = {
    owner_email = var.owner_email_tag
  }
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
  tags = {
    owner_email = var.owner_email_tag
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

  tags = {
    owner_email = var.owner_email_tag
  }
}

### Kafka Rest Proxy 

resource "azurerm_public_ip" "krp_pip" {
  count               = var.krp_count
  name                = "${var.resource_group_name}-${var.subnet_name}-krp_pip-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.resource_group_name}-${var.subnet_name}-krp-${count.index}"
  tags = {
    owner_email = var.owner_email_tag
  }
}

resource "azurerm_dns_cname_record" "public_dns_krp_record" {
  count               = var.krp_count
  name                = "${var.resource_group_name}-${var.subnet_name}-krp_record-${count.index}"
  zone_name           = data.azurerm_dns_zone.dns_zone.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  ttl                 = "300"
  record              = azurerm_public_ip.krp_pip[count.index].fqdn
  tags = {
    owner_email = var.owner_email_tag
  }
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
  tags = {
    owner_email = var.owner_email_tag
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
  tags = {
    owner_email = var.owner_email_tag
  }
}

### Control Center 

resource "azurerm_public_ip" "c3_pip" {
  count               = var.c3_count
  name                = "${var.resource_group_name}-${var.subnet_name}-c3_pip-${count.index}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.resource_group_name}-${var.subnet_name}-c3-${count.index}"
  tags = {
    owner_email = var.owner_email_tag
  }
}

resource "azurerm_dns_cname_record" "public_dns_c3_record" {
  count               = var.c3_count
  name                = "${var.resource_group_name}-${var.subnet_name}-c3_record-${count.index}"
  zone_name           = data.azurerm_dns_zone.dns_zone.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  ttl                 = "300"
  record              = azurerm_public_ip.c3_pip[count.index].fqdn
  tags = {
    owner_email = var.owner_email_tag
  }
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
  tags = {
    owner_email = var.owner_email_tag
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
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = "latest"
  }
  tags = {
    owner_email = var.owner_email_tag
  }
}
resource "azurerm_managed_disk" "c3_disk" {
  count                = var.c3_count
  name                 = "${var.resource_group_name}-${var.subnet_name}-c3-disk-${count.index}"
  location             = data.azurerm_resource_group.resource_group.location
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  storage_account_type = var.c3_disk_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.c3_disk_size
  tags = {
    owner_email = var.owner_email_tag
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "c3_disk_attachment" {
  count = var.c3_count
  managed_disk_id    = azurerm_managed_disk.c3_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.c3[count.index].id
  lun                = count.index + 30
  caching            = var.c3_disk_cache_policy
}
