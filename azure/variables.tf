# Azure Resource variable
variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group"
}

variable "vnet_name" {
  type        = string
  description = "Azure Existing Resource Group VNET "
}

variable "subnet_name" {
  type        = string
  description = "Azure subnet name to be created within existing VNET "
}

variable "subnet_addres_prefix" {
  type        = string
  description = "CIDR prefixes to the subnet to be created"
}

variable "user_name" {
  type        = string
  description = "user name used for VMs admin and pub key users"
}

variable "pub_key_path"{
    type = string
    description = "local path to pub key"
}

variable "zk_count" {
  description = "Zookeeper Instances to be created. Default 3"
  default = 3
}

variable "source_image_publisher" {
    type = string
    description = "VM Source Image Publisher. Default Canonical"
    default = "Canonical"
}


variable "source_image_offer" {
    type = string
    description = "VM Source Image Offer. Default UbuntuServer"
    default = "UbuntuServer"
}

variable "source_image_sku" {
    type = string
    description = "VM Source Image sku (SO version). Default 18_04-lts-gen2"
    default = "18_04-lts-gen2"
}

variable "zk_vm_type" {
  type = string
  description = "Zookeeper Virtual Machine type to be created. Default (to match Confluent standard requirements): Standard_D4_v3"
  default = "Standard_D4s_v3"
}

variable "zk_data_disk_cache_policy" {
  type = string
  description = "Zookeeper Virtual Machine data disk Caching policy. Default: ReadWrite"
  default = "ReadWrite"
}

variable "zk_data_disk_storage_account_type" {
  type = string
  description = "Zookeeper Virtual Machine Storage Account type. Default: Standard_LRS"
  default = "Standard_LRS"
}

variable "zk_data_disk_size" {
  description = "Zookeeper data disk size. Default 1024Gb"
  default = 1024
}

variable "zk_data_disk_count" {
  description = "number of Zookeeper transaction log disks. Default 2"
  default = 2
}

variable "zk_log_disk_cache_policy" {
  type = string
  description = "Zookeeper Virtual Machine log disk Caching policy. Default: ReadWrite"
  default = "ReadWrite"
}

variable "zk_log_disk_storage_account_type" {
  type = string
  description = "Zookeeper log disk Storage Account type. Default: Standard_LRS"
  default = "Standard_LRS"
}

variable "zk_log_disk_size" {
  description = "Zookeeper log disk size. Default 512Gb"
  default = 512
}

variable "zk_log_disk_count" {
  description = "number of Zookeeper data disks. Default 1"
  default = 1
}

variable "broker_count" {
  description = "Kafka Broker Instances to be created. Default 3"
  default = 3
}

variable "broker_vm_type" {
  type = string
  description = "Kafka Broker Virtual Machine type to be created. Default: Standard_D8_v3"
  default = "Standard_D8s_v3"
}
variable "broker_log_disk_cache_policy" {
  type = string
  description = "Kafka Broker log disk Caching policy. Default: ReadWrite"
  default = "ReadWrite"
}

variable "broker_log_disk_storage_account_type" {
  type = string
  description = "Kafka Broker log disk Storage Account type. Default: Standard_LRS"
  default = "Standard_LRS"
}

variable "broker_log_disk_size" {
  description = "Kafka Broker log disk size. Default 512Gb"
  default = 1024
}

variable "broker_log_disk_count" {
  description = "number of Kafka Broker log  disks. Default 2"
  default = 2
}

variable "sr_count" {
  description = "Schema Registry Instances to be created. Default 1"
  default = 1
}

variable "sr_vm_type" {
  type = string
  description = "Schema Registry Virtual Machine type to be created. Default: Standard_D4_v3"
  default = "Standard_D4s_v3"
}

variable "sr_disk_cache_policy" {
  type = string
  description = "Schema Registry Virtual Machine disk Caching policy. Default: ReadWrite"
  default = "ReadWrite"
}

variable "sr_disk_storage_account_type" {
  type = string
  description = "Schema Registry Virtual Machine Storage Account type. Default: Standard_LRS"
  default = "Standard_LRS"
}

variable "connect_count" {
  description = "Kafka Connect Instances to be created. Default 2"
  default = 2
}

variable "connect_vm_type" {
  type = string
  description = "Kafka Connect Virtual Machine type to be created. Default: Standard_D4_v3"
  default = "Standard_D4s_v3"
}

variable "connect_disk_cache_policy" {
  type = string
  description = "Kafka Connect Virtual Machine disk Caching policy. Default: ReadWrite"
  default = "ReadWrite"
}

variable "connect_disk_storage_account_type" {
  type = string
  description = "Kafka Connect Virtual Machine Storage Account type. Default: Standard_LRS"
  default = "Standard_LRS"
}

variable "replicator_count" {
  description = "Replicator Instances to be created. Default 0"
  default = 0
}

variable "replicator_vm_type" {
  type = string
  description = "Replicator Virtual Machine type to be created. Default: Standard_D4_v3"
  default = "Standard_D4s_v3"
}

variable "replicator_disk_cache_policy" {
  type = string
  description = "Replicator Virtual Machine disk Caching policy. Default: ReadWrite"
  default = "ReadWrite"
}

variable "replicator_disk_storage_account_type" {
  type = string
  description = "Replicator Virtual Machine Storage Account type. Default: Standard_LRS"
  default = "Standard_LRS"
}
variable "ksql_count" {
  description = "KsqlDB Instances to be created. Default 1"
  default = 1
}

variable "ksql_vm_type" {
  type = string
  description = "KsqlDB Virtual Machine type to be created. Default: Standard_D8s_v3"
  default = "Standard_D8s_v3"
}

variable "ksql_disk_cache_policy" {
  type = string
  description = "KsqlDB Virtual Machine disk Caching policy. Default: ReadWrite"
  default = "ReadWrite"
}

variable "ksql_disk_storage_account_type" {
  type = string
  description = "KsqlDB Virtual Machine Storage Account type. Default: Standard_LRS"
  default = "Standard_LRS"
}

variable "krp_count" {
  description = "Kafka Rest Proxy Instances to be created. Default 0"
  default = 0
}

variable "krp_vm_type" {
  type = string
  description = "Kafka Rest Proxy Virtual Machine type to be created. Default: Standard_D8s_v3"
  default = "Standard_D8s_v3"
}

variable "krp_disk_cache_policy" {
  type = string
  description = "Kafka Rest Proxy Virtual Machine disk Caching policy. Default: ReadWrite"
  default = "ReadWrite"
}

variable "krp_disk_storage_account_type" {
  type = string
  description = "Kafka Rest Proxy Virtual Machine Storage Account type. Default: Standard_LRS"
  default = "Standard_LRS"
}

variable "c3_count" {
  description = "Control Center Instances to be created. Default 1"
  default = 1
}

variable "c3_vm_type" {
  type = string
  description = "Control Center Virtual Machine type to be created. Default: Standard_D4_v3"
  default = "Standard_D4s_v3"
}

variable "c3_disk_cache_policy" {
  type = string
  description = "Control Center Virtual Machine disk Caching policy. Default: ReadWrite"
  default = "ReadWrite"
}

variable "c3_disk_storage_account_type" {
  type = string
  description = "Control Center Virtual Machine Storage Account type. Default: Standard_LRS"
  default = "Standard_LRS"
}

variable "c3_disk_size" {
  description = "Kafka Broker log disk size. Default 128Gb (reduced mode)"
  default = 128
}

variable "owner_email_tag" {
  description = "Azure resource owner email"
  default = "ogomezsoriano@confluent.io"
}