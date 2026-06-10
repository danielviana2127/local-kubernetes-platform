# Incident Simulation - ImagePullBackOff

## Objetivo

Demonstrar o processo de identificação, investigação e resolução de falhas relacionadas ao download de imagens de containers em Kubernetes.

Este incidente foi reproduzido em ambiente controlado para demonstrar técnicas de troubleshooting utilizadas no dia a dia de profissionais DevOps, SRE e Infraestrutura.

---

# Ambiente

| Componente    | Valor            |
| ------------- | ---------------- |
| Kubernetes    | Minikube         |
| Namespace     | development      |
| Deployment    | nginx-deployment |
| Tipo de Falha | ImagePullBackOff |

---

# Cenário

Durante uma atualização do Deployment NGINX, foi configurada uma imagem inexistente:

```text
nginx:999999
```

O Deployment foi criado com sucesso pelo Kubernetes, porém o Pod não conseguiu baixar a imagem do registry.

---

# Sintoma

Verificação dos Pods:

```bash
kubectl get pods -n development
```

Resultado observado:

```text
nginx-deployment-6bd4b98c96-shkft   0/1   ImagePullBackOff
```

Enquanto isso, as demais réplicas da aplicação continuavam operacionais:

```text
nginx-deployment-58f9959b5-b7sjb   1/1   Running
nginx-deployment-58f9959b5-mj56v   1/1   Running
```

---

# Investigação

Foi realizada uma análise detalhada do Pod afetado.

Comando utilizado:

```bash
kubectl describe pod nginx-deployment-6bd4b98c96-shkft -n development
```

Eventos encontrados:

```text
Failed to pull image "nginx:999999"
manifest unknown
ErrImagePull
ImagePullBackOff
```

Esses eventos indicam que o Kubernetes tentou baixar a imagem diversas vezes, mas o registry não encontrou a tag especificada.

---

# Análise do ReplicaSet

Foi realizada a inspeção do ReplicaSet responsável pela criação do Pod.

Comando utilizado:

```bash
kubectl describe rs nginx-deployment-6bd4b98c96 -n development
```

Resultado:

```text
Image: nginx:999999
```

O ReplicaSet estava associado à revisão 3 do Deployment.

```text
deployment.kubernetes.io/revision: 3
```

---

# Causa Raiz (Root Cause Analysis)

A imagem configurada no Deployment utilizava uma tag inexistente:

```text
nginx:999999
```

O registry Docker Hub não possui essa versão da imagem NGINX.

Consequentemente:

1. O Kubernetes tentou baixar a imagem.
2. O registry retornou erro.
3. O Pod entrou em estado ErrImagePull.
4. O Kubernetes iniciou tentativas automáticas de recuperação.
5. O estado evoluiu para ImagePullBackOff.

---

# Impacto

* O Pod não foi iniciado.
* O ReplicaSet não conseguiu atingir o estado desejado.
* O Kubernetes continuou tentando recuperar o workload automaticamente.
* A aplicação principal permaneceu disponível graças às demais réplicas saudáveis.

---

# Correção

A imagem foi corrigida para uma tag válida.

Exemplo:

```yaml
image: nginx:latest
```

Ou utilizando:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:latest -n development
```

Após a atualização do Deployment, um novo ReplicaSet foi criado utilizando uma imagem válida.

---

# Validação

Verificação dos Pods:

```bash
kubectl get pods -n development
```

Resultado esperado:

```text
STATUS: Running
READY: 1/1
```

Verificação do Deployment:

```bash
kubectl get deployment nginx-deployment -n development
```

Resultado esperado:

```text
READY 2/2
AVAILABLE 2
```

---

# Conceitos Demonstrados

* Kubernetes Deployments
* ReplicaSets
* Pod Lifecycle
* Container Images
* Docker Registry
* Rollout Management
* Troubleshooting Kubernetes
* Root Cause Analysis (RCA)
* Incident Response
* High Availability

---

# Lições Aprendidas

* Validar imagens e tags antes de realizar deploys.
* Utilizar pipelines CI/CD para validar manifestos Kubernetes.
* Monitorar eventos do Kubernetes para diagnóstico rápido.
* Manter múltiplas réplicas reduz o impacto de falhas individuais.
* Conhecer o fluxo de investigação acelera a resolução de incidentes.

---

# Evidências

Adicionar os seguintes screenshots:

```text
docs/screenshots/imagepullbackoff-pod.png
docs/screenshots/imagepullbackoff-events.png
docs/screenshots/imagepullbackoff-replicaset.png
```

Comandos utilizados para gerar as evidências:

```bash
kubectl get pods -n development

kubectl describe pod nginx-deployment-6bd4b98c96-shkft -n development

kubectl describe rs nginx-deployment-6bd4b98c96 -n development
```

---

# Resultado Final

O incidente foi identificado, analisado e corrigido utilizando ferramentas nativas do Kubernetes, demonstrando um fluxo completo de troubleshooting e resposta a incidentes em ambiente containerizado.