#!/bin/bash

# Name current node jump-server
kubectl label nodes jump-server nodeName=jump-server

# Create namespaces 
kubectl create namespace cert-manager
kubectl create namespace infra
kubectl create namespace argocd
kubectl create namespace monitoring
kubectl create namespace istio-system
kubectl create namespace logging

# Start certificate management service
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.1/cert-manager.yaml
sleep 15
kubectl apply -f cert-manager.yaml

# Start registry
kubectl apply -f registry.yaml
kubectl wait --for=condition=Ready pod -n infra -l app=registry --timeout=300s
kubectl apply -f registry-ingress.yaml

# Build and push Jenkins Docker image
docker build -t registry.aleksvagapitov.com/custom-jenkins:lts jenkins/
docker push registry.aleksvagapitov.com/custom-jenkins:lts

# Start Jenkins service
cp /root/.kube/config /root/.kube/jenkins-config
sed -i 's|127.0.0.1:6443|kubernetes.default.svc:443|g' /root/.kube/jenkins-config
kubectl apply -f jenkins.yaml
kubectl wait --for=condition=Ready pod -n infra -l app=jenkins --timeout=300s
kubectl apply -f jenkins-ingress.yaml

# Copy Jenkins password
sleep 15
kubectl cp infra/$(kubectl get pods -n infra -l app=jenkins -o jsonpath="{.items[0].metadata.name}"):var/jenkins_home/secrets/initialAdminPassword ~/jenkinsPassword

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=Ready pod -n argocd -l app.kubernetes.io/name=argocd-server --timeout=300s
kubectl patch configmap argocd-cm -n argocd --type merge -p '{"data":{"server.insecure": "true"}}'
kubectl rollout restart deployment argocd-server -n argocd
kubectl apply -f argocd-ingress.yaml

# Install Loki
kubectl apply -f loki.yaml 
kubectl apply -f promtail.yaml 
kubectl apply -f loki-ingress.yaml 

# Install Jaeger
kubectl create namespace observability
kubectl apply -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.45.0/jaeger-operator.yaml -n observability
kubectl apply -f jaeger.yaml
kubectl apply -f jaeger-ingress.yaml

# Install Prometheus
kubectl apply --server-side -f https://github.com/prometheus-operator/prometheus-operator/releases/latest/download/bundle.yaml
kubectl apply -f prometheus.yaml
kubectl apply -f prometheus-ingress.yaml

# Install Grafana
kubectl apply -f grafana.yaml
kubectl wait --for=condition=Ready pod -n monitoring -l app=grafana --timeout=300s
kubectl apply -f grafana-ingress.yaml

echo "Setup complete."