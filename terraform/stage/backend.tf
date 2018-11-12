terraform {
  backend "gcs" {
    bucket = "terraform-state-storage-bucket"
  }
}
