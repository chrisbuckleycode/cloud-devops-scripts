variable "region" {
  type    = string
  default = "us-east-1"
}

variable "rest_api_name" {
  default     = "api-gateway-example-PetStore"
  type        = string
}

variable "stage_name" {
  default     = "beta"
  type        = string
}
