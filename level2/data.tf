data "terraform_remote_state" "layer1" {
  backend = "s3"

  config = {
    bucket = "cloud-learning-bucket112"
    key    = "layer1.tfstate"
    region = "eu-west-1"
  }
}