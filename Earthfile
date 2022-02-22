VERSION 0.6

ARG ansible_extra_args

DEPS:
  COMMAND
  # TODO add other requried tools
  RUN which minikube && which kubectl && which tkn && which helm

UPDATE_HELM_REPOS:
  COMMAND
  RUN helm repo update

WORK_ENV:
  COMMAND
  RUN mkdir -p ./work
  RUN touch ./work/.envrc
  
DIRENV:
  COMMAND
  ARG dir=.
  RUN direnv allow "$dir"

RUN_ANSIBLE_GALAXY:
  COMMAND
  ARG galaxy_target
  ARG file=./requirements.yml
  RUN ansible-galaxy "$galaxy_target" install -r "$file" --ignore-errors

RUN_ANSIBLE_PLAYBOOK:
  COMMAND
  ARG playbook_file
  #  $(if $ansible_extra_args =  "true"; then printf -- "$ansible_extra_args"; fi)
  RUN ansible-playbook "$playbook_file"

INSTALL_TEKTON_TASK:
  COMMAND
  ARG task
  ARG version
  ARG kube_context
  RUN tkn hub install task "$task" --version="$version" --context="$kube_context"

CREATE_CIVO_CLUSTER:
  COMMAND
  ARG cluster_name
  ARG cluster_size=g4p.kube.small
  ARG cluster_region=LON1
  ARG cluster_nodes=1
  RUN civo k3s create "$cluster_name" \
    --applications="-Traefik" \
    --nodes="$cluster_nodes" \
    --region="$cluster_region" \
    --size="$cluster_size" --wait

SAVE_CIVO_KUBECONFIG:
  COMMAND
  ARG cluster_name
  RUN civo k3s config "$cluster_name" -p "$KUBECONFIG" --save --merge

setup:
  LOCALLY

  DO +DIRENV --dir=.
  DO +RUN_ANSIBLE_GALAXY --galaxy_target="role"
  DO +RUN_ANSIBLE_GALAXY --galaxy_target="collection"
  DO +WORK_ENV

clean:
  LOCALLY
  
  DO +RUN_ANSIBLE_PLAYBOOK --playbook_file=./cleanup.yml
  DO +DIRENV --dir=.

civo-clusters:
  LOCALLY

  DO +CREATE_CIVO_CLUSTER --cluster_name="mgmt"
  DO +SAVE_CIVO_KUBECONFIG --cluster_name="mgmt"

  DO +CREATE_CIVO_CLUSTER --cluster_name="cluster1" \
    --cluster_size='g4p.kube.medium' \
    --cluster_nodes=2
  DO +SAVE_CIVO_KUBECONFIG --cluster_name="cluster1"

clusters:
  LOCALLY
  
  DO +DIRENV --dir=.
  DO +RUN_ANSIBLE_PLAYBOOK --playbook_file=./clusters.yml
  DO +DIRENV --dir=.

gitea:
  LOCALLY
  
  DO +DIRENV --dir=.
  DO +UPDATE_HELM_REPOS
  DO +RUN_ANSIBLE_PLAYBOOK --playbook_file=./gitea.yml
  DO +DIRENV --dir=.

argocd:
  LOCALLY
  
  DO +DIRENV --dir=.
  DO +UPDATE_HELM_REPOS
  DO +RUN_ANSIBLE_PLAYBOOK --playbook_file=./argocd.yml
  DO +DIRENV --dir=.

gloo:
  LOCALLY
  
  DO +DIRENV --dir=.
  DO +UPDATE_HELM_REPOS
  DO +RUN_ANSIBLE_PLAYBOOK --playbook_file=./gloo.yml
  DO +DIRENV --dir=.

pipelines:
  LOCALLY
  
  DO +DIRENV --dir=.
  DO +UPDATE_HELM_REPOS
  DO +RUN_ANSIBLE_PLAYBOOK --playbook_file=./pipelines.yml
  DO +DIRENV --dir=.

extras:
  LOCALLY
  
  DO +DIRENV --dir=.
  DO +UPDATE_HELM_REPOS
  DO +RUN_ANSIBLE_PLAYBOOK --playbook_file=./extras.yml
  DO +DIRENV --dir=.

install-pipeline-tasks:
  LOCALLY

  DO +INSTALL_TEKTON_TASK --task="maven" --version="0.2" --kube_context="$CLUSTER1"
  DO +INSTALL_TEKTON_TASK --task="git-clone" --version="0.5" --kube_context="$CLUSTER1"
  DO +INSTALL_TEKTON_TASK --task="buildah" --version="0.3" --kube_context="$CLUSTER1"
  DO +INSTALL_TEKTON_TASK --task="openshift-client" --version="0.2" --kube_context="$CLUSTER1"

all:
  BUILD +clusters
  BUILD +gitea
  BUILD +argocd
  BUILD +extras
  BUILD +gloo
  BUILD +pipelines
  BUILD +install-pipeline-tasks
