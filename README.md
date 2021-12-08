# Fruits App Demo

The fruits demo  Gitops repository that will be used to demonstrate the GitOps base API deployment with Gloo Portal. This GitOps repository will be used to deploy the [Fruits API](https://github.com/kameshsampath/fruits-api).

Please check the [HTML Documentation](https://kameshsampath.github.io/fruits-api-gitops) for complete setup.

## Using Cluster1

```shell
kubectl config use-context $CLUSTER1
```

## Setup

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

tkn hub install task buildah \
  --version=0.3 \
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
kustomize build  pipelines | envsubst | kubectl apply --context $CLUSTER1 -f -
```

## Tekton Triggers

Get the gloo gateway-proxy LoadBalancer ip,

```shell
export GLOO_GATEWAY_PROXY_IP="$(kubectl --context="$CLUSTER1" -n gloo-system  get svc gateway-proxy -ojsonpath='{.status.loadBalancer.ingress[*].ip}')"
```

Create Tekton Triggers that will run the image build once changes are pushed to fruits-api,

```bash
kustomize build triggers  | envsubst | kubectl apply --context $CLUSTER1 -f -
```

## Build and Deploy

## Argocd

```shell
# Ensures colors are also removed form output
export TARGET_CLUSTER="$(kubectl --context="$CLUSTER1" cluster-info | sed 's/\x1b\[[0-9;]*m//g' | awk 'NR==1{print $7}')"
yq eval '.spec.destination.server = strenv(TARGET_CLUSTER)' manifests/app/app.yaml | kubectl apply --context="$MGMT" -n argocd -f - 
```

### Manual Trigger Pipeline

Build and Deploy the fruits-api image,

```shell
tkn pipeline start fruits-api-deploy \
  --context="$CLUSTER1" \
  --namespace=default \
  --serviceaccount=pipeline \
  --param git-url=https://gitea-192.168.64.81.nip.io/gitea/fruits-api \
  --param git-ssl-verify=false \
  --param image-name=quay.io/kameshsampath/fruits-api \
  --workspace name=maven-settings,config=maven-settings \
  --workspace name=git-source,claimName=fruits-api-git-source \
  --use-param-defaults \
  --showlog
```

## Pom Version Task

```shell
tkn task start pom-version \
  --context="$CLUSTER1" \
  --namespace=default \
  --serviceaccount=pipeline \
  --workspace name=maven-settings,config=maven-settings \
  --workspace name=source,claimName=fruits-api-git-source \
  --use-param-defaults \
  --showlog
```