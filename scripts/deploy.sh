#!/usr/bin/env bash
set -euo pipefail

# Sempre executa a partir da raiz do repositório, independente de onde foi chamado
cd "$(dirname "$0")/.."

NAMESPACE="development"
HOST="local-app.dev"

echo ">> Verificando pré-requisitos..."
for cmd in kubectl minikube; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERRO: '$cmd' não encontrado no PATH." >&2
    exit 1
  fi
done

if ! minikube status >/dev/null 2>&1; then
  echo "ERRO: o Minikube não está em execução. Rode: minikube start" >&2
  exit 1
fi

kubectl cluster-info >/dev/null

echo ">> Habilitando o NGINX Ingress Controller..."
minikube addons enable ingress

echo ">> Aguardando o Ingress Controller ficar pronto..."
kubectl wait --namespace ingress-nginx \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo ">> Aplicando recursos Kubernetes..."
kubectl apply -f kubernetes/namespaces/
kubectl apply -f kubernetes/deployments/
kubectl apply -f kubernetes/services/
kubectl apply -f kubernetes/ingress/

echo ">> Aguardando o deployment ficar disponível..."
kubectl rollout status deployment/nginx-deployment \
  --namespace "$NAMESPACE" \
  --timeout=120s

echo
echo ">> Deploy concluído com sucesso."
kubectl get pods,svc,ingress --namespace "$NAMESPACE"

echo
echo "Para acessar a aplicação:"
echo "  1) Adicione ao /etc/hosts:  $(minikube ip) $HOST"
echo "  2) Se usar o driver Docker, rode em outro terminal: minikube tunnel"
echo "     (e use 127.0.0.1 $HOST no /etc/hosts)"
echo "  3) Acesse: http://$HOST"