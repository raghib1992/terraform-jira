Hostname is calcuated by taking the prefixname, adding ":ponyo" to the name, and taking the first 10 digits of the sha256sum of that string
example:
name_prefix = "bobzrkr"
hostname = substr(sha256("${var.name_prefix}:ponyo"),-10,-1)


This is still very much a work in progress. To move between regions/trial-names a lot of settings need to be changed/confirmed. Also a new ssh key will need to be created in AWS

Variables in terraform.tfvars to check/change:
* region
* ecs_ami (specific to each region)
* domainname (so far only have us1.saas.securecircle.com:us-west-2 and ap1.saas.securecircle.com:ap-south-1)
* name_prefix 
* route53_zone_id (different for different domains)
* key_name (ssh key you should have created earlier)

Variabls in providers.tf to check/change: 
* provider.region

run 'terraform init --reconfigure --backend-config key=sc-saas/${name_prefix}' 

replace ${name_prefix} with actual value. Terraform can't handle variable names in backend configs
