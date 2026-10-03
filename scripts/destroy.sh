#!/usr/bin/env bash
set -euo pipefail

# Sempre executa a partir da raiz do repositório, independente de onde foi chamado
cd "$(dirname "$0")/.."

if ! command -v kubectl >/dev/null 2>&1; then
  echo "ERRO: 'kubectl' não encontrado no PATH." >&2
  exit 1
fi

echo ">> Removendo recursos da aplicação..."
kubectl delete -f kubernetes/ingress/ --ignore-not-found
kubectl delete -f kubernetes/services/ --ignore-not-found
kubectl delete -f kubernetes/deployments/ --ignore-not-found

# Remove o namespace por último (apaga tudo que ainda existir dentro dele)
kubectl delete -f kubernetes/namespaces/ --ignore-not-found

echo
echo ">> Recursos removidos."
echo "   O Minikube e o addon de Ingress continuam ativos."
echo "   Para parar o cluster:      minikube stop"
echo "   Para apagar o cluster:     minikube delete"