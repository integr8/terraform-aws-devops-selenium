variable "availability-zones" {
  type = "list"
}

variable "vpc-id" {}

variable "subnets" {
  type = "list"
}

variable "cluster-name" {
  default = "selenium-cluster"
}

variable "bucket-name-prefix" {
  default = "selenium-config-"
}

variable "ami" {
  default = "ami-aff65ad2"
}

variable "instance-type" {
  default = "m4.xlarge"
}
