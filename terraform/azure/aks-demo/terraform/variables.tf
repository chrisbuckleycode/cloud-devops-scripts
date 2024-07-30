variable "prefix" {
  description = "Company/Division prefix"
  type    = string
  default = "sf001"
}

variable "project" {
  type    = string
  default = "maranello"
}

variable "environment" {
  description = "e.g. dev, test, acc, prod"
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "eastus"
}


locals {
  #resourceGroupName  = "rg-${var.prefix}-${var.project}-${var.environment}-${var.location}"

  # static reference if forced to use pre-existing RG
  resourceGroupName = ""
  aksName = "k8s-${var.prefix}-${var.project}-${var.environment}-${var.location}"
}
