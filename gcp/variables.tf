# GCP resource variables
variable "broker_count" {
  default = 3
}

variable "zookeeper_count" {
  default = 3
}

variable "registry_count" {
  default = 1
}

variable "ccc_count" {
  default = 1
}

variable "connect_count" {
  default = 1
}

variable "pub_key_path" {
  type = string
  description = "local path to pub key"
}

variable "resource_name_prefix" {
  type = string
  description = "common prefix for all resources"
}

variable "gcp_vpc_name" {
  type = string
  description = "name of the existing google compute network to be used"
}

variable "gcp_subnet_name" {
  type = string
  description = "name of the existing google compute sub network to be used"
}

variable "gcp_project_name" {
  type = string
  description = "name of the existing google compute project to be used"
}

variable "gcp_region" {
  type = string
  description = "name of the region to be used"
}

variable "cidr_range" {
  type = string
  default = "10.1.0.0/16"
}

variable "broker_cidr_prefix" {
  type = string
  default = "10.1.1."
  description = "CIDR prefix used by the broker nodes"
}

variable "zk_cidr_prefix" {
  type = string
  default = "10.1.2."
  description = "CIDR prefix used by the zookeeper nodes"
}

variable "connect_cidr_prefix" {
  type = string
  default = "10.1.3."
  description = "CIDR prefix used by the connect nodes"
}

variable "registry_cidr_prefix" {
  type = string
  default = "10.1.4."
  description = "CIDR prefix used by the registry nodes"
}

variable "ccc_cidr_prefix" {
  type = string
  default = "10.1.5."
  description = "CIDR prefix used by the Control Center nodes"
}

variable "ingress_workstation_source_range" {
  type = list(string)
  description = "List of workstation CIDR range which can access to the platform"
}

variable "broker_disk_type" {
  type = string
  default = "pd-standard"
  description = "Type of GCP disks to be used for broker nodes"
}

variable "broker_disk_size" {
  type = number
  default = 50
  description = "Size of GCP disks to be used for broker nodes"
}

variable "broker_machine_type" {
  type = string
  default = "e2-standard-2"
  description = "Type of GCP machine to be used for broker nodes"
}

variable "zk_machine_type" {
  type = string
  default = "e2-standard-2"
  description = "Type of GCP machine to be used for zookeeper nodes"
}

variable "registry_machine_type" {
  type = string
  default = "e2-standard-2"
  description = "Type of GCP machine to be used for registry nodes"
}

variable "connect_machine_type" {
  type = string
  default = "e2-standard-2"
  description = "Type of GCP machine to be used for Kafka Connect nodes"
}

variable "ccc_machine_type" {
  type = string
  default = "e2-standard-2"
  description = "Type of GCP machine to be used for Control Center nodes"
}

variable "os_image_name" {
  type = string
  default = "ubuntu-2004-focal-v20220905"
  description = "OS image name to be used"
}
