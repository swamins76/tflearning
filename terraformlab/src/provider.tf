provider "aws" {
  alias  = "east"
  region = "us-east-1"

}
provider "aws" {
  alias  = "west"
  region = "us-west-1"

}
terraform {
  backend "s3" {
    region = "us-east-1"
    key    = "terraform.tfstate"
    bucket = "myterraform2022"
  }
}
