# Common

variable "namespace" {
  type = string
}

variable "stage" {
  type = string
}

variable "default_region" {
  type = string
}

variable "tags" {
  type = map(string)
}

# Local

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}