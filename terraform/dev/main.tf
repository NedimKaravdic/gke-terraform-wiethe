locals {
  env = "dev"
}

terraform {
  backend "gcs" {
    bucket = "wiethecgi-dev-tf-state"
    credentials = "wiethecgi-key.json"
  }
}

provider google {
  project = "${var.project_id}"
  region  = "${var.region}"
  zone    = "${var.zone}"
  impersonate_service_account = var.tf_service_account

}

provider "google-beta" {

  project = "${var.project_id}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

module "gke" {
  source = "../modules/gke"

  env                   = "${local.env}"
  image_tag             = "${var.commit_hash}"
  k8s_master_allowed_ip = "${var.k8s_master_allowed_ip}"
  machine_type          = "n1-standard-1"
  network_name          = "gke-network"
  node_count            = "1"
  region                = "${var.region}"
}

module "assets" {
  source = "../modules/assets"

  env      = "${local.env}"
  location = "${var.region}"
}

module "lb" {
  source = "../modules/lb"

  assets_bucket_name       = "${module.assets.bucket_name}"
  enable_cdn               = true
  k8s_backend_service_name = "${var.k8s_backend_service_name}"
}

module "dns" {
  source = "../modules/dns"

  domain                   = "${var.domain}"
  load_balancer_ip_address = "${module.lb.public_address}"
}

data "template_file" "k8s" {
  template = "${file("${path.module}/../k8s.template.yml")}"

  vars = {
    db_host      = "${module.cloud_sql.host}"
    db_name      = "${module.cloud_sql.db_name}"
    db_username  = "${module.cloud_sql.username}"
    db_password  = "${module.cloud_sql.password}"
    db_port      = "5432"
    image_url    = "${module.gke.image_url}"
    project_name = "gke-${local.env}"
  }
}
