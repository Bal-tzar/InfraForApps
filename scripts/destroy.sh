#!/bin/bash

#variables

POSTGRES_PASSWORD="otto"

cd /home/otto/Documents/Projects/Examensarbete/PaytrackR/PaytrackR/Terraform

terraform destroy -var="postgres_admin_password=${POSTGRES_PASSWORD}" -auto-approve