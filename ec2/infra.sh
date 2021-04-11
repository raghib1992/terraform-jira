#!/bin/bash

AWS_SECRET=$1
sed -i "s|aws-password|$AWS_SECRET|g" terraform.tfvars
ssh-keygen -f test-key
chmod 400 test-key