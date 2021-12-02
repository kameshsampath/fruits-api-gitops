# Fruits App Demo

A simple fruits API demo with Gloo Edge

# Tools and Frameworks

- [tektoncd](https://tekton.dev)

# Using Cluster1

```shell
kubectl config use-context $CLUSTER1
```

# Setup

Install tektoncd,

```bash
kubectl apply \
   --context="$CLUSTER1" \
   --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
```

Deploy nexus to use for building java applications,

```bash
kubectl apply \
  --context $CLUSTER1 \
  --filename https://raw.githubusercontent.com/redhat-scholars/tekton-tutorial/master/install/utils/nexus.yaml
```

```bash
tkn hub install task maven \
  --version=0.2 \
  --context="$CLUSTER1"
  
tkn hub install task git-clone \
  --version=0.5 \
  --context="$CLUSTER1"

tkn hub install task kaniko \
  --version=0.5 \
  --context="$CLUSTER1"
  
tkn hub install task openshift-client \
   --version=0.2 \
  --context="$CLUSTER1" 
```

## Tekton pipelines,

Create the pipeline that will help us build the fruits-api application,

```bash
kubectl apply --context $CLUSTER1 --kustomize pipelines
```

## Tekton Triggers

Get the gloo gateway-proxy LoadBalancer ip,

```shell
export GLOO_GATEWAY_PROXY_IP="$(glooctl proxy address | cut -d':' -f1)"
```

Create Tekton Triggers that will run the image build once changes are pushed to fruits-api,

```bash
kustomize build triggers  | envsubst | kubectl apply --context $CLUSTER1 -f -
```

## Build and Deploy

## using Argocd

```shell
# Ensures colors are also removed form output
export TARGET_CLUSTER="$(kubectl --context=cluster1 cluster-info | sed 's/\x1b\[[0-9;]*m//g' | awk 'NR==1{print $7}')"
yq eval '.spec.destination.server = strenv(TARGET_CLUSTER)' manifests/app/app.yaml | kubectl apply --context="$MGMT" -n argocd -f - 
```

Building via triggers.

__TODO__: automate via task

- Create a git repository on gitea with name `fruits-api`
- Push the sources of fruits-api to it
- Add Gitea webhook pointing to 'https://el-gitea-webhook-${GLOO_GATEWAY_PROXY_IP}.nip.io'
- Trigger test delivery to see the pipeline getting started

### Manual Trigger Pipeline

Build and Deploy the fruits-api image,

```
tkn pipeline start fruits-api-deploy \
  --namespace=default \
  --serviceaccount=openshift-client-sa \
  --workspace name=maven-settings,config=maven-settings \
  --workspace name=git-source,claimName=fruits-api-git-source \
  --use-param-defaults \
  --showlog
```