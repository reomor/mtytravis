provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  source           = "../modules/app"
  project          = "${var.project}"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  zone             = "${var.zone}"
  app_disk_image   = "${var.app_disk_image}"
  db_internal_ip   = "${module.db.db_internal_ip}"
}

module "db" {
  source           = "../modules/db"
  project          = "${var.project}"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  zone             = "${var.zone}"
  db_disk_image    = "${var.db_disk_image}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["176.120.238.103/32"]
}
