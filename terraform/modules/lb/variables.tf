variable "assets_bucket_name" {
  type = string
  default = "wiethecgi-dev-tf-state"
}

variable "enable_cdn" {
  type    = bool
  default = true
}

variable "k8s_backend_service_name" {
  type    = string
  default = "wiethe-backend"
}
