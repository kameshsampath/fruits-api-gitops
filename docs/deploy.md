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

## Ensure Environment

---8<--- "includes/env.md"

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

#### [openshift-client](https://hub.tekton.dev/tekton/task/openshift-client)

```shell
tkn hub install task openshift-client \
   --version=0.2 \
  --context="$CLUSTER1" 
```

## Create Tektoncd pipelines

As the piplines will build and push the container image to [ghcr.io](https://github.com/features/packages) it is required to have the following two variables set in your enviroment,

```shell
export GITHUB_USERNAME=<your github username>
```

```shell
export GHCR_PASSWORD=<your Github PAT>
```

!!!important
    `GHCR_PASSWORD` is the [GitHub PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with the following permissions:

     - repo **read** access
     - package **write** access

Create the pipeline `fruits-api-deploy`,

```bash
kustomize build  pipelines \
  | envsubst \
  | kubectl apply --context $CLUSTER1 -f -
```

## Tekton Triggers

The Tekton Triggers take care of rebuilding the application as and when the new code is committed into the Git repository.

Get the gloo `gateway-proxy` LoadBalancer ip to configure the gloo routes and the same will be used to configure the Git Webhooks later,

```shell
export GLOO_GATEWAY_PROXY_IP="$(kubectl --context="$CLUSTER1" -n gloo-system  get svc gateway-proxy -ojsonpath='{.status.loadBalancer.ingress[*].ip}')"
```

Verify to see if it has value set,

```shell
echo "${GLOO_GATEWAY_PROXY_IP}"
```

Create Tekton Triggers that will run the image build once changes are pushed to fruits-api,

```bash
kustomize build triggers  \
  | envsubst | kubectl apply --context $CLUSTER1 -f -
```

Wait for the Gitea event listener webhook to be running,

```shell
kubectl --context=$CLUSTER1 \
  rollout status deploy/el-gitea-webhook --timeout=120s
```

## Create the dev remote to Gitea

```shell
export FRUITS_API_GITOPS_REPO_URL="https://gitea-$(kubectl --context="$MGMT" -n gitea  get svc gateway-proxy -ojsonpath='{.status.loadBalancer.ingress[*].ip}').nip.io/gitea/fruits-api-gitops.git"
git remote add dev $FRUITS_API_GITOPS_REPO_URL
```

Commit and push the local code to the Gitea repository.

```shell
git commit -a -m "Repo Init"
git push dev main
```

The default Gitea credentials is `gitea/password`.

## GitOps with Argocd

## Add Gitea Repository to Argocd

As the Gitea repository we will be using local and uses self signed certificates, let us configure that in Argocd to skip `sslVerify`,

Login to Argocd,

```shell
# make sure we are in mgmt kubernetes context
kubectl config use-context mgmt
argocd login --insecure $(yq e '.serviceUrl' $DEMO_WORK_DIR/argocd_details.yaml) \
  --username "${ARGOCD_ADMIN_USERNAME}" --password="${ARGOCD_ADMIN_PASSWORD}"
```

Add the local Gitea repository,

```shell
argocd repo add "$(yq e '.gitea_url' work/gitea_details.yaml)/${GITEA_USERNAME}/fruits-api-gitops.git" --username "${GITEA_USERNAME}" --password "${GITEA_PASSWORD}" --insecure-skip-server-verification
```

## Create Application

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