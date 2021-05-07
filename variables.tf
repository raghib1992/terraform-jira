variable "route53_zone_id" {
}

variable "region" {
  description = "The region of AWS, for AMI lookups, does used in provider location"
}

variable "name_prefix" {
  default = "noname"
  description = "Prefix for all AWS resource names"
}

variable "domainname" {
  type = string
  default = "ap1.saas.securecircle.com"
}

variable "db_instance_type" {
  type = string
  default = "db.t2.micro"
}

variable "instance_type" {
  default = "t3a.small"
}

variable "vpc_cidr_block" {
  type = string
  default = "192.168.180.0/24"
  description = "VPC CIDR Block"
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = [
    "192.168.180.0/26",
    "192.168.180.64/26"
  ]
  description = "Subnet ranges"
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = [
    "192.168.180.128/26",
    "192.168.180.192/26"
  ]
  description = "Subnet ranges"
}

variable "saas_alerts_emails" {
  default = [ "josh.jones@securecircle.com", "steve.bouche@securecircle.com", "george.anderson@securecircle.com" ]
}

variable "eipcount" {
  default = 2
}

variable "percent_on_demand" {
  default = 10
}

variable "encrypt_db" {
  default = true
}

variable "saas_db_dump_s3_destination_bucket" {
  default = ""
}

variable "saas_db_dump_s3_destination_prefix" {
  default = ""
}

variable "wopi_enabled" {
  default = false
}

variable "wopi_url" {
  default = ""
}

variable "base_domain_alias" {
  default = "SecureCircle Server"
}

variable "asg_lt_instance_type_overrides" {
  type = map(list(object({instance_type = string})))
  default = {
    us-west-2 = [
      {
        instance_type = "t3a.small"
      },
      {
        instance_type = "t3.small"
      },
      {
        instance_type = "t2.medium"
      },
      {
        instance_type = "m5a.large"
      },
      {
        instance_type = "m5.large"
      },
      {
        instance_type = "m4.large"
      },
      {
        instance_type = "c5.large"
      },
      {
        instance_type = "c4.large"
      }
    ],
    us-east-2 = [
      {
        instance_type = "t3a.small"
      },
      {
        instance_type = "t3.small"
      },
      {
        instance_type = "t2.medium"
      },
      {
        instance_type = "m5a.large"
      },
      {
        instance_type = "m5.large"
      },
      {
        instance_type = "m4.large"
      },
      {
        instance_type = "c5.large"
      },
      {
        instance_type = "c4.large"
      }
    ],
    ap-south-1 = [
      {
        instance_type = "t3a.small"
      },
      {
        instance_type = "t3.small"
      },
      {
        instance_type = "t2.medium"
      },
      {
        instance_type = "m5a.large"
      },
      {
        instance_type = "m5.large"
      },
      {
        instance_type = "m4.large"
      },
      {
        instance_type = "c5.large"
      },
      {
        instance_type = "c4.large"
      }
    ],
    ap-northeast-1 = [
      {
        instance_type = "t3a.small"
      },
      {
        instance_type = "t3.small"
      },
      {
        instance_type = "t2.medium"
      },
      {
        instance_type = "m5a.large"
      },
      {
        instance_type = "m5.large"
      },
      {
        instance_type = "m4.large"
      },
      {
        instance_type = "c5.large"
      },
      {
        instance_type = "c4.large"
      }
    ]
    eu-west-1 = [
      {
        instance_type = "t3a.small"
      },
      {
        instance_type = "t3.small"
      },
      {
        instance_type = "t2.medium"
      },
      {
        instance_type = "m5a.large"
      },
      {
        instance_type = "m5.large"
      },
      {
        instance_type = "m4.large"
      },
      {
        instance_type = "c5.large"
      },
      {
        instance_type = "c4.large"
      }
    ],
    me-south-1 = [
      {
        instance_type = "t3.small"
      },
      {
        instance_type = "t3.medium"
      },
      {
        instance_type = "m5.large"
      },
      {
        instance_type = "c5.large"
      }
    ],
    sa-east-1 = [
      {
        instance_type = "t3a.small"
      },
      {
        instance_type = "t3.small"
      },
      {
        instance_type = "t2.medium"
      },
      {
        instance_type = "m5a.large"
      },
      {
        instance_type = "m5.large"
      },
      {
        instance_type = "m4.large"
      },
      {
        instance_type = "c5.large"
      },
      {
        instance_type = "c4.large"
      }
    ]
  }
}

variable "kms_key_id" {
  default = ""
}

variable "lambda-saas-db-dump-cron-expression" {
  type = string
  default = "cron(0 0 ? * SUN *)"
}

variable "lambda-saas-db-dump-rsa-pubkey" {
  type = string
  default = ""
}

variable "ipsec_vpn_map" {
  type = map(object({
      remote_private_subnet_cidrs = list(string)
      dynamic = bool
    })
  )
  default = {}
}

variable "agent_upload_enabled" {
  type = bool
  default = false
}

variable "agent_upload_bucket" {
  default = "sc-saas-clients"
  description = "Bucket to upload agent artifacts to"
}

variable "agent_upload_region" {
  default = "us-east-2"
  description = "Region of agent_upload_bucket"
}

variable "config_bucket" {
  default = "sc-saas-config"
  description = "Bucket to upload custom configuration to"
}

variable "config_bucket_region" {
  default = "us-east-2"
  description = "Region of config_bucket"
}

variable "sc_purpose" {
  default = "saas"
  description = "Either saas (production) or trial"
}

variable "glowroot_enabled" {
  type = bool
  default = false
}

variable "glowroot_subnets" {
  type = list(string)
  default = [
    "96.72.187.0/29"
  ]
  description = "Subnet ranges"
}
