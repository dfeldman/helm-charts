#!/bin/bash

kubectl create namespace spire-system
kubectl label namespace spire-system pod-security.kubernetes.io/enforce=privileged
kubectl create namespace spire-server
kubectl label namespace spire-server pod-security.kubernetes.io/enforce=restricted

helm install cert-manager cert-manager --namespace cert-manager --create-namespace --version v1.11.0 --set installCRDs=true --repo https://charts.jetstack.io --wait
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
kubectl apply -f $SCRIPT_DIR/testcert.yaml -n spire-server

helm install ingress-nginx ingress-nginx --version 4.5.2 --repo https://kubernetes.github.io/ingress-nginx --create-namespace -n ingress-nginx --set controller.extraArgs.enable-ssl-passthrough= --wait

helm upgrade --install --namespace spire-server spire charts/spire -f examples/production/values.yaml -f examples/production/values-export-ingress-nginx.yaml --wait

ip=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o go-template='{{ .spec.clusterIP }}')
echo $ip oidc-discovery.example.org

kubectl get secret -n spire-server tls-cert -o go-template='{{ index .data "ca.crt" | base64decode }}' > /tmp/ca

curl --cacert /tmp/ca --resolve oidc-discovery.example.org:443:$ip https://oidc-discovery.example.org/.well-known/openid-configuration
