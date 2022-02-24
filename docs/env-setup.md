---
title: Environment Setup
summary: Quick and easy way to publish your APIs using solo.io Gloo 

authors:
- Kamesh Sampath<kamesh.sampath@hotmail.com>

date: 2021-12-06
---

At the end of this chapter you will have,

- [x] Two minikube clusters `mgmt` and `cluster1`

- [x] `mgmt` cluster will have Argocd and Gitea git repository manager

- [x] `cluster1` will have Tektoncd, Gloo Edge and Portal deployed

## Ensure Python venv

To create the virtual environment run the following command,

```bash
direnv allow .
```

The command will instal all the required python modules in the `$DEMO_HOME/.direnv`.

Install the ansible roles and collections that will be used by the playbooks,

```bash
make install-roles-and-collections
```

## Setup Kubernetes Environment

With Ansible environment ready we are all good to setup demo environment with required components installed.

Copy the `$DEMO_HOME/vars.yml` to `$DEMO_HOME/vars.local.yml` and edit the values to suit your environment.

### Minikube clusters

The minikube clusters could be created by running:

```bash
make create-kube-clusters
```

!!!important
      The order of the deployment in the following section is crucial as **Argocd** and **Pipelines** is dependent on the **gitea** deployment and its details.

### Deploy Gitea

The Gitea git repository manager could by deployed by running:

```bash
make deploy-gitea
```

!!! note
    It will take few minutes for Gitea to be installed

The Gitea details are stored in the file `$DEMO_WORK_DIR/gitea-details.yaml`.

### Deploy Argocd

The Argocd could by deployed by:

```bash
make deploy-argocd
```

The Argocd details are stored in the file `$DEMO_WORK_DIR/argocd-details.yaml`.

### Deploy Gloo Edge and Portal

The Gloo Edge enterprise and portal could be deployed via,

```bash
make deploy-gloo
```

### Deploy Tektoncd

The Tektoncd could by deployed by:

```bash
make deploy-pipelines
```

### Extras

To make the demo builds faster we will use sonatype nexus repository manager, it be deployed by,

```bash
make deploy-extras
```

The installation apart from installing the components, it will also download the companion tools such as `tkn`, `gitea`, `glooctl`, `kubectl` etc., on to `$DEMO_HOME/bin`.

## Demo Sources

### Fruits API GitOps

Clone the `fruits-api-gitops` demo sources from the GitHub repository,

```shell
cd ..
git clone https://github.com/kameshsampath/fruits-api-gitops
```

For convenience, we will refer the clone demo sources folder as `$DEMO_HOME`,

```shell
export DEMO_HOME="$PWD"
```

Add the git `dev` remote to Gitea,

```shell
export FRUITS_API_GITOPS_REPO_URL="$GITEA_URL/gitea/fruits-api-gitops.git"
git remote add dev $FRUITS_API_GITOPS_REPO_URL
```

Commit and push the local code to the dev `remote`,

```shell
git commit -a -m "Demo Setup"
git push dev main
```

### Fruits API

Clone the `fruits-api` demo sources,

```shell
cd ..
git clone https://github.com/kameshsampath/fruits-api
cd fruits-api
```

Add Gitea repo as `dev` remote,

```shell
export FRUITS_API_REPO_URL="$GITEA_URL/gitea/fruits-api.git"
git remote add dev $FRUITS_API_REPO_URL
```

Navigate to the gitops sources,

```bash
cd $DEMO_HOME
```
