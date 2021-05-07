region = "ap-south-1"
domainname = "ap2.saas.securecircle.com"
route53_zone_id = "Z094983412SWQ8ROLJFN8"
name_prefix = "raghib"
base_domain_alias = "raghib demo"
agent_upload_enabled = true
sc_purpose = "trial"
percent_on_demand = 0
instance_type = "t3a.small"
asg_lt_instance_type_overrides = {
  ap-south-1 = [
    {
      instance_type = "t3a.small"
    },
    {
      instance_type = "t3.small"
    },
    {
      instance_type = "t3a.medium"
    },
    {
      instance_type = "t3.medium"
    },
    {
      instance_type = "t2.medium"
    },
    {
      instance_type = "t3a.large"
    },
    {
      instance_type = "c5a.large"
    },
    {
      instance_type = "t3.large"
    }
  ]
}
