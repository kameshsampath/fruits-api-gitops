SHELL := bash
CURRENT_DIR = $(shell pwd)
ENV_FILE := $(CURRENT_DIR)/.envrc

create-venv:
	direnv allow .
  pip install -r requirements.txt
  pip install -r https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements-azure.txt

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

tools:
	direnv allow $(ENV_FILE)
	@ansible-playbook tools.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

test:
	direnv allow $(ENV_FILE)
	@ansible-playbook test.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

