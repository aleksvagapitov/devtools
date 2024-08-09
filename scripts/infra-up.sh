#!/bin/bash

# Name current node jump-server
kubectl label nodes jump-server nodeName=jump-server

# Create namespaces 
kubectl create namespace cert-manager
kubectl create namespace infra

# Start certificate management service
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.1/cert-manager.yaml
sleep 15
kubectl apply -f cert-manager.yaml

# Start registry
kubectl apply -f registry.yaml
kubectl wait --for=condition=Ready pod -n infra -l app=registry --timeout=300s
kubectl apply -f registry-ingress.yaml

# Build docker image for jenkins
docker build -t registry.aleksvagapitov.com/custom-jenkins:lts jenkins/
docker push registry.aleksvagapitov.com/custom-jenkins:lts

# Start jenkins service and copy jenkins password
cp /root/.kube/config /root/.kube/jenkins-config
sed -i 's|127.0.0.1:6443|kubernetes.default.svc:443|g' /root/.kube/jenkins-config
kubectl apply -f jenkins.yaml
kubectl wait --for=condition=Ready pod -n infra -l app=jenkins --timeout=300s
kubectl apply -f jenkins-ingress.yaml

# Copy jenkins password
sleep 15
kubectl cp infra/$(kubectl get pods -n infra -l app=jenkins -o jsonpath="{.items[0].metadata.name}"):var/jenkins_home/secrets/initialAdminPassword ~/jenkinsPassword
