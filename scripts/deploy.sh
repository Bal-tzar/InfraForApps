#!/bin/bash

#variables

POSTGRES_PASSWORD="otto"

cd ../Terraform

terraform init
terraform apply -var="postgres_admin_password=${POSTGRES_PASSWORD}" -auto-approve
sleep 10m

az aks get-credentials --resource-group paytrackr-rg --name paytrackr-aks --overwrite-existing


cd ../k8s

kubectl apply -f namespace.yaml
kubectl apply -f secret.yaml
kubectl apply -f configmap.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f monitoring/grafana-deployment.yaml
kubectl apply -f monitoring/prometheus-config.yaml
kubectl apply -f monitoring/prometheus-deployment.yaml

sleep 2m

kubectl get svc -n paytrackr