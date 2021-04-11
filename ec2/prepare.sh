#!/bin/bash

NEW_CUSTOMER=$1

git checkout $NEW_CUSTOMER

sed -i "s|newcustomer|$NEW_CUSTOMER|g" terraform.tfvars
