provider "aws" {
  region = var.master-region
  alias  = "master-region"

}
provider "aws" {
  region = var.worker-region
  alias  = "worker-region"

}
provider "aws" {
  alias  = "east"
  region = "us-east-1"

}
