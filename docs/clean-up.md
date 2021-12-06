---
title: Envrionment Cleanup
summary: Delete the minikube cluster.
authors:
  - Kamesh Sampath
date: 2021-12-06
---

At the end of this chapter you would have,

- [x] Delete minikube clusters

## Ensure Environment

Navigate to Tutorial home

```bash
cd $TUTORIAL_HOME
```

Set cluster environment variables

---8<--- "includes/env.md"

## Destroy minikube clusters

```bash
make clean-up
```
