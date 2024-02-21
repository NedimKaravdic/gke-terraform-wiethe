variable "env" {
  type = string
  default = "dev"
}

variable "location" {
  default = "europe-west3"
  type    = string
}

variable "storage_class" {
  default = "REGIONAL"
  type    = string
}
