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