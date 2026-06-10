# Troubleshooting Guide

## Objetivo

Este documento reúne problemas comuns encontrados durante a administração da plataforma Kubernetes local e os procedimentos utilizados para diagnóstico e resolução.

---

# Pods não iniciam

## Verificar status dos Pods

```bash
kubectl get pods -A
```

## Obter detalhes do Pod

```bash
kubectl describe pod <pod-name> -n <namespace>
```

## Verificar logs

```bash
kubectl logs <pod-name> -n <namespace>
```

---

# Ingress não responde

## Verificar Ingress

```bash
kubectl get ingress -A
```

## Descrever recurso

```bash
kubectl describe ingress nginx-ingress -n development
```

## Verificar Controller

```bash
kubectl get pods -n ingress-nginx
```

---

# Service não encontra Pods

## Verificar Services

```bash
kubectl get svc -A
```

## Verificar Endpoints

```bash
kubectl get endpoints -A
```

## Validar Labels

```bash
kubectl get pods --show-labels -n development
```

---

# Prometheus não coleta métricas

## Verificar Pods

```bash
kubectl get pods -n monitoring
```

## Logs do Prometheus

```bash
kubectl logs -n monitoring deployment/prometheus
```

## Targets

Acessar:

```text
http://localhost:9090/targets
```

---

# Grafana não exibe dashboards

## Verificar Pods

```bash
kubectl get pods -n monitoring
```

## Logs do Grafana

```bash
kubectl logs -n monitoring deployment/grafana
```

## Verificar Datasource

Grafana → Connections → Data Sources

---

# Verificação Geral da Plataforma

```bash
kubectl get all -A
```

```bash
kubectl top nodes
```

```bash
kubectl top pods -A
```

```bash
kubectl get ingress -A
```

```bash
kubectl get svc -A
```