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

variable "jenkins_repo_name" {
    type = string
}