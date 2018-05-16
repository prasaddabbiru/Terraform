terraform {
  backend "s3" {
    bucket = "rdd-bucket-f1234"
    key    = "terraform/state"
    region = "eu-west-1"
  }
}
