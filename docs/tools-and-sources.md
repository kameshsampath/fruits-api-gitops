---
title: Tools and Sources 

summary: Tools and demo sources that are required for this tutorial. 

authors:

- Kamesh Sampath date: 2021-09-03

---

At the end of this chapter you will have the required tools and enviroment ready for running the demo.

## Assumptions

---8<--- "includes/tools.md"

!!! important
   You will need Gloo Mesh Enterprise License Key to run the demo exercises. If you dont have one, get a trial license from [solo.io](https://lp.solo.io/request-trial).

## Demo Sources

Clone the demo sources from the GitHub respository,

```shell
git clone https://github.com/kameshsampath/fruits-api-gitops
cd fruits-api-gitops
```

For convinience, we will refer the clone demo sources folder as `$TUTORIAL_HOME`,

```shell
export TUTORIAL_HOME="$PWD"
```

Navigate to the project home,

```bash
cd $TUTORIAL_HOME
```