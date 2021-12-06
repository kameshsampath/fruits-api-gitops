SHELL := bash
CURRENT_DIR = $(shell pwd)
ENV_FILE := $(CURRENT_DIR)/.envrc
POETRY_COMMAND := $(shell which poetry)

create-venv:
	@$(POETRY_COMMAND) install

install-roles-and-collections:
	@$(POETRY_COMMAND) run ansible-galaxy role install -r requirements.yml
	@$(POETRY_COMMAND) run ansible-galaxy collection install -r requirements.yml

shell-env:
	@$(POETRY_COMMAND) shell

lint:	
	@ansible-lint --force-color

clean-up:
	@$(POETRY_COMMAND) run ansible-playbook cleanup.yml  $(EXTRA_ARGS)

create-kube-clusters:
	direnv allow $(ENV_FILE)
	@$(POETRY_COMMAND) run ansible-playbook clusters.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

all:
	direnv allow $(ENV_FILE)
	@$(POETRY_COMMAND) run ansible-playbook playbook.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

deploy-argocd:
	direnv allow $(ENV_FILE)
	@$(POETRY_COMMAND) run ansible-playbook argocd.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

deploy-extras:
	direnv allow $(ENV_FILE)
	@$(POETRY_COMMAND) run ansible-playbook extras.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

deploy-pipelines:
	direnv allow $(ENV_FILE)
	@$(POETRY_COMMAND) run ansible-playbook pipelines.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

deploy-gloo:
	direnv allow $(ENV_FILE)
	@$(POETRY_COMMAND) run ansible-playbook gloo.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

deploy-gitea:
	direnv allow $(ENV_FILE)
	@$(POETRY_COMMAND) run ansible-playbook gitea.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

deploy-registry:
	direnv allow $(ENV_FILE)
	@$(POETRY_COMMAND) run ansible-playbook registry.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

tools:
	direnv allow $(ENV_FILE)
	@$(POETRY_COMMAND) run ansible-playbook tools.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

test:
	direnv allow $(ENV_FILE)
	@$(POETRY_COMMAND) run ansible-playbook test.yml $(EXTRA_ARGS)
	direnv allow $(ENV_FILE)

