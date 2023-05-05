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

variable "ksqldb_count" {
  default = 1
}

variable "aws_credential_files" {
  type = list(string)
  description = "local path to AWS credentials"
}

variable "aws_key_pair" {
  type = string
  description = "AWS key pair"
}

variable "aws_security_group" {
  type = string
  description = "AWS security group"
}

variable "aws_zone" {
  type = string
  description = "AWS route53 zone"
}

variable "resource_name_prefix" {
  type = string
  description = "common prefix for all resources"
}

variable "aws_region" {
  type = string
  description = "name of the region to be used"
}

variable "broker_disk_type" {
  type = string
  default = "gp3"
  description = "Type of AWS disks to be used for broker nodes"
}

variable "broker_disk_size" {
  type = number
  default = 50
  description = "Size of AWS disks to be used for broker nodes"
}

variable "ccc_disk_type" {
  type = string
  default = "gp3"
  description = "Type of AWS disks to be used for ccc nodes"
}

variable "ccc_disk_size" {
  type = number
  default = 50
  description = "Size of AWS disks to be used for ccc nodes"
}


variable "zk_disk_type" {
  type = string
  default = "gp3"
  description = "Type of AWS disks to be used for zk nodes"
}

variable "zk_disk_size" {
  type = number
  default = 50
  description = "Size of AWS disks to be used for zk nodes"
}

variable "broker_machine_type" {
  type = string
  default = "t2.large"
  description = "Type of AWS machine to be used for broker nodes"
}

variable "zk_machine_type" {
  type = string
  default = "t2.large"
  description = "Type of AWS machine to be used for zookeeper nodes"
}

variable "registry_machine_type" {
  type = string
  default = "t2.large"
  description = "Type of AWS machine to be used for registry nodes"
}

variable "connect_machine_type" {
  type = string
  default = "t2.large"
  description = "Type of AWS machine to be used for Kafka Connect nodes"
}

variable "ksqldb_machine_type" {
  type = string
  default = "t2.large"
  description = "Type of AWS machine to be used for Kafka KSqldb nodes"
}

variable "ccc_machine_type" {
  type = string
  default = "t2.large"
  description = "Type of AWS machine to be used for Control Center nodes"
}

variable "os_image_name" {
  type = string
  default = "ami-0cc4e06e6e710cd94" # Ubuntu 20.04 LTS
  description = "OS image name to be used"
}