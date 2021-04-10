#!/bin/bash

NEW_CUSTOMER=$1

echo "**** Creating new branch*****"
git checkout $NEW_CUSTOMER
echo "**** BRANCH FOR $NEW_CUSTOMER CREATED SUCCESSFULLY****"

sed -i 's/newcustomer/$NEW_CUSTOMER/g' ec2/terraform.tfvars
git add .
git commit "change new branch for customer $NEW_CUSTOMER"
git push origin $NEW_CUSTOMER
