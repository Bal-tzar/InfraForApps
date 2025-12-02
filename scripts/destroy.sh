#!/bin/bash

#variables

POSTGRES_PASSWORD="otto"

cd ../terraform/

terraform destroy -var="postgres_admin_password=${POSTGRES_PASSWORD}" -auto-approve