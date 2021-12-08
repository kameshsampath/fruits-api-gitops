---
title: Tools and Sources 

summary: Tools and demo sources that are required for this tutorial. 

authors:

- Kamesh Sampath 

date: 2021-09-03

---

At the end of this chapter you will have the required tools and enviroment ready for running the demo.

---8<--- "includes/tools.md"

!!! important
   You will need Gloo Mesh Enterprise License Key to run the demo exercises. If you dont have one, get a trial license from [solo.io](https://lp.solo.io/request-trial).

## Demo Sources

### Fruits API

Clone the `fruits-api` demo sources,

```shell
git clone https://github.com/kameshsampath/fruits-api
cd fruits-api
```

Add Gitea repo as `dev` remote,

```shell
export FRUITS_API_REPO_URL="https://gitea-$(kubectl --context="$MGMT" -n gitea  get svc gateway-proxy -ojsonpath='{.status.loadBalancer.ingress[*].ip}').nip.io/gitea/fruits-api.git"
git remote add dev $FRUITS_API_REPO_URL
```

### Fruits API GitOps

Clone the `fruits-api-gitops` demo sources from the GitHub respository,

```shell
cd ..
git clone https://github.com/kameshsampath/fruits-api-gitops
```

For convinience, we will refer the clone demo sources folder as `$DEMO_HOME`,

```shell
export DEMO_HOME="$PWD"
```

Navigate to the gitops sources,

```bash
cd $DEMO_HOME
```

Add the git `dev` remote to Gitea,

```shell
export FRUITS_API_GITOPS_REPO_URL="https://gitea-$(kubectl --context="$MGMT" -n gitea  get svc gateway-proxy -ojsonpath='{.status.loadBalancer.ingress[*].ip}').nip.io/gitea/fruits-api-gitops.git"
git remote add dev $FRUITS_API_GITOPS_REPO_URL
```

Commit and push the local code to the dev `remote`,

```shell
git commit -a -m "Repo Init"
git push dev main
```
