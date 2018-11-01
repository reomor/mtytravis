provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage-bucket" {
  source  = "Sweetops/storage-bucket/google"
  version = "0.1.1"

  name = ["sb-tst1", "sb-tst2"]
}

output storage-bucket_url {
  value = "${module.storage-bucket.url}"
}
