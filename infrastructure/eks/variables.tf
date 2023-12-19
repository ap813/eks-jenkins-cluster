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

variable "cluster_name" {
  type = string
}

# Local

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}