---
title: Deploy API
summary: Deploy the Fruits API Pipeline and Argocd applications
authors:
  - Kamesh Sampath
date: 2021-12-06
---

At the end of chapter you would have,

- [x] Deployed Tekton tasks and pipelines reuqired to build Fruits API
- [x] Deployed the Argocd Application to deploy Fruits API
- [x] Configure the Fruits API Webhook with Gitea

## Pipelines

As part of the demo we will be using [tektoncd](https://tekton.dev) pipelines to build and push the image to the container registry.

### Deploy Tektoncd Tasks

The following Tektoncd community tasks will be used by the FruitsAPI as part of the application build, since tektoncd does not install these out of the box we wil install them manually,

#### [maven](https://hub.tekton.dev/tekton/task/maven)

```shell
tkn hub install task maven \
  --version=0.2 \
  --context="$CLUSTER1"
```
  
#### [git-clone](https://hub.tekton.dev/tekton/task/git-clone)

```shell
tkn hub install task git-clone \
  --version=0.5 \
  --context="$CLUSTER1"
```

#### [buildah](https://hub.tekton.dev/tekton/task/buildah)

```shell
tkn hub install task buildah \
  --version=0.3 \
  --context="$CLUSTER1"
```

#### [kaniko](https://hub.tekton.dev/tekton/task/kaniko)

```shell
tkn hub install task kaniko \
  --version=0.5 \
  --context="$CLUSTER1"
```

#### [openshift-client](https://hub.tekton.dev/tekton/task/openshift-client)

```shell
tkn hub install task openshift-client \
   --version=0.2 \
  --context="$CLUSTER1" 
```

## Create Tektoncd pipelines

Create the pipeline that will help us build the fruits-api application,

```bash
kustomize build  pipelines | envsubst | kubectl apply --context $CLUSTER1 -f -
```

## Tekton Triggers

The Tekton Triggers take care of rebuilding the application as and when the new code is pushed into the Git repository.

Get the gloo gateway-proxy LoadBalancer ip to configure the gloo routes and the same will be used to configure the Git Webhooks later,

```shell
export GLOO_GATEWAY_PROXY_IP="$(kubectl --context="$CLUSTER1" -n gloo-system  get svc gateway-proxy -ojsonpath='{.status.loadBalancer.ingress[*].ip}')"
```

Create Tekton Triggers that will run the image build once changes are pushed to fruits-api,

```bash
kustomize build triggers  | envsubst | kubectl apply --context $CLUSTER1 -f -
```

## GitOps

Query the `cluster1` info to get the cluster API URL and run the following command to create `fruits-api` ArgoCD application.

```bash
# Ensures colors are also removed form output
export TARGET_CLUSTER="$(kubectl --context="$CLUSTER1" cluster-info | sed 's/\x1b\[[0-9;]*m//g' | awk 'NR==1{print $7}')"
yq eval '.spec.destination.server = strenv(TARGET_CLUSTER)' manifests/app/app.yaml | kubectl apply --context="$MGMT" -n argocd -f - 
```

The Argocd application will apply the helm chart `$DEMO_HOME/charts/fruits-api using Helm values from $DEMO_HOME/helm_vars/fruits-api/values.yaml`.

The helm values supports by the chart are,

```yaml
---8<--- "charts/fruits-api/values.yaml"
```

