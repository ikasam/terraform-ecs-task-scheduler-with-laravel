provider "aws" {
  version = "~> 2.0"
  region  = var.region
  profile = var.profile
}

provider "template" {
  version = "~> 2.1"
}