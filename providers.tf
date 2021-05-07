provider "aws" {
  region = var.region
  version = "~> 2.0"
  ignore_tags {
    key_prefixes = ["custom/"]
  }
}

provider "aws" {
  region = var.agent_upload_region
  alias = "agent_upload_region"
  ignore_tags {
    key_prefixes = ["custom/"]
  }
}

provider "aws" {
  region = var.config_bucket_region
  alias = "config_bucket_region"
  ignore_tags {
    key_prefixes = ["custom/"]
  }
}

locals {
  common_tags = {
    sc_purpose = var.sc_purpose
    sc_customer = var.name_prefix
  }
}

data "aws_caller_identity" "current" {}

provider "mysql" {
  endpoint = aws_db_instance.scdb.endpoint
  username = aws_db_instance.scdb.username
  password = aws_db_instance.scdb.password
  version = "~> 1.5"
}

provider "template" {
  version = "~> 2.1"
}

terraform {
  backend "s3" {
    bucket = "sc-saas-terraform"
    region = "us-west-2"
    skip_credentials_validation = true
  }
}
