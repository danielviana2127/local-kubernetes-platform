#!/usr/bin/env bash
set -euo pipefail

# Sempre executa a partir da raiz do repositório, independente de onde foi chamado
cd "$(dirname "$0")/.."

NAMESPACE="monitoring"
RELEASE="monitoring"

echo ">> Verificando pré-requisitos..."
for cmd in kubectl helm minikube; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERRO: '$cmd' não encontrado no PATH." >&2
    exit 1
  fi
done

if ! minikube status >/dev/null 2>&1; then
  echo "ERRO: o Minikube não está em execução. Rode: minikube start" >&2
  exit 1
fi

echo ">> Habilitando o Metrics Server..."
minikube addons enable metrics-server

echo ">> Adicionando o repositório Helm do Prometheus..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update

echo ">> Instalando o kube-prometheus-stack (Prometheus, Grafana, kube-state-metrics, node-exporter)..."
helm upgrade --install "$RELEASE" prometheus-community/kube-prometheus-stack \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --wait \
  --timeout 10m

echo
echo ">> Monitoramento instalado."
kubectl get pods --namespace "$NAMESPACE"

echo
echo "Para acessar o Grafana:"
echo "  kubectl port-forward -n $NAMESPACE svc/${RELEASE}-grafana 3000:80"
echo "  Usuário: admin"
echo "  Senha:   kubectl get secret -n $NAMESPACE ${RELEASE}-grafana -o jsonpath=\"{.data.admin-password}\" | base64 -d; echo"
echo
echo "Para acessar o Prometheus:"
echo "  kubectl port-forward -n $NAMESPACE svc/${RELEASE}-kube-prometheus-prometheus 9090:9090"