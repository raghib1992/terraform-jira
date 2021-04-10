#!/bin/bash

NEW_CUSTOMER=$1

git checkout -b $NEW_CUSTOMER

sed -i "s|newcustomer|$NEW_CUSTOMER|g" terraform.tfvars

git add .

git commit -m "change new branch for customer $NEW_CUSTOMER"

git push origin $NEW_CUSTOMER
