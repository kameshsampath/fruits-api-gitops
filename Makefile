SHELL := bash
CURRENT_DIR = $(shell pwd)
ENV_FILE := $(CURRENT_DIR)/.envrc

create-venv:
	direnv allow .
	pip install -r requirements.txt
	pip install -r https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements-azure.txt
	mkdir -p $(DEMO_WORK_DIR)

install-roles-and-collections:
	@ansible-galaxy role install -r requirements.yml
	@ansible-galaxy collection install -r requirements.yml

lint:	
	@ansible-lint --force-color

clean-up:
	@ansible-playbook cleanup.yml  $(EXTRA_ARGS)

create-kube-clusters:
	direnv allow $(ENV_FILE)
	@ansible-playbook clusters.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

all:
	direnv allow $(ENV_FILE)
	@ansible-playbook playbook.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

deploy-argocd:
	direnv allow $(ENV_FILE)
	@ansible-playbook argocd.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

deploy-extras:
	direnv allow $(ENV_FILE)
	@ansible-playbook extras.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

deploy-pipelines:
	direnv allow $(ENV_FILE)
	@ansible-playbook pipelines.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

deploy-gloo:
	direnv allow $(ENV_FILE)
	@ansible-playbook gloo.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

deploy-gitea:
	direnv allow $(ENV_FILE)
	@ansible-playbook gitea.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

deploy-registry:
	direnv allow $(ENV_FILE)
	@ansible-playbook registry.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

install-pipeline-tasks:
	tkn hub install task maven \
  --version=0.2 \
  --context="$(CLUSTER1)"
	tkn hub install task git-clone \
  --version=0.5 \
  --context="$(CLUSTER1)"
	tkn hub install task buildah \
		--version=0.3 \
		--context="$(CLUSTER1)"
	tkn hub install task openshift-client \
   --version=0.2 \
  --context="$(CLUSTER1)"

warm-m2-cache:	install-pipeline-tasks
	kubectl --context=$(CLUSTER1) apply -f $(CURRENT_DIR)/pipelines/m2-cache.yaml

tools:
	direnv allow $(ENV_FILE)
	@ansible-playbook tools.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

test:
	direnv allow $(ENV_FILE)
	@ansible-playbook test.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

