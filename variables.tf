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

variable "zk_disk_cache_policy" {
  type = string
  description = "Zookeeper Virtual Machine disk Caching policy. Default: ReadWrite"
  default = "ReadWrite"
}

variable "zk_disk_storage_account_type" {
  type = string
  description = "Zookeeper Virtual Machine Storage Account type. Default: Standard_LRS"
  default = "Standard_LRS"
}

variable "broker_count" {
  description = "Kafka Broker Instances to be created. Default 3"
  default = 3
}

variable "broker_vm_type" {
  type = string
  description = "Zookeeper Virtual Machine type to be created. Default: Standard_D8_v3"
  default = "Standard_D8s_v3"
}

variable "broker_disk_cache_policy" {
  type = string
  description = "Kafka Broker Virtual Machine disk Caching policy. Default: ReadWrite"
  default = "ReadWrite"
}

variable "broker_disk_storage_account_type" {
  type = string
  description = "Kafka Broker Virtual Machine Storage Account type. Default: Standard_LRS"
  default = "Standard_LRS"
}