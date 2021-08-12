.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN (FS = ":.*?## "); (printf "\033[36m%-30s\033[0m %s\n", $$1, $$2)'

SHELL := /bin/bash
BASH_CMD := $(SHELL) -c
COMMIT_HASH ?= $(shell git rev-parse --short HEAD)

IMAGE_NAME ?= mkdocs
IMAGE_VERSION ?= latest
IMAGE_TAG = $(IMAGE_NAME):$(IMAGE_VERSION)

SITE_NAME ?= Sample-Site
DOCS_SRC ?= docs
DOCS_DIR ?= processed
REPO_URL ?= https://gitlab.com/motowilliams/mkdocs-test/
SITE_DIR ?= site
SITE_URL ?= https://example.com/

ifdef CI
	export REPO_ROOT := $(PWD)
	export DOCS_SRC_PATH=$(REPO_ROOT)/$(DOCS_SRC)
	export DOCS_PROCESSED_PATH=$(REPO_ROOT)/$(DOCS_DIR)
	export DOCS_SITE_PATH=$(REPO_ROOT)/$(SITE_DIR)
	export DOCS_ENV_PATH=$(REPO_ROOT)/env
	export DOCKER_COMMAND :=
else
	export REPO_ROOT := /app
	export DOCS_SRC_PATH=$(REPO_ROOT)/$(DOCS_SRC)
	export DOCS_PROCESSED_PATH=$(REPO_ROOT)/$(DOCS_DIR)
	export DOCS_SITE_PATH=$(REPO_ROOT)/$(SITE_DIR)
	export DOCS_ENV_PATH=$(REPO_ROOT)/env
	export DOCKER_COMMAND := docker run -it \
		-v $(PWD):$(REPO_ROOT) \
		--env CI=TRUE \
		--env COMMIT_HASH=$(COMMIT_HASH) \
		--env DOCS_DIR=$(DOCS_DIR) \
		--env DOCS_ENV_PATH=$(DOCS_ENV_PATH) \
		--env DOCS_PROCESSED_PATH=$(DOCS_PROCESSED_PATH) \
		--env DOCS_SITE_PATH=$(DOCS_SITE_PATH) \
		--env DOCS_SRC_PATH=$(DOCS_SRC_PATH) \
		--env REPO_ROOT=$(REPO_ROOT) \
		--env REPO_URL=$(REPO_URL) \
		--env SITE_DIR=$(SITE_DIR) \
		--env SITE_NAME="$(SITE_NAME)" \
		--env SITE_URL=$(SITE_URL) \
		--rm \
		-w $(REPO_ROOT) \
		-p 8000:8000 \
		$(IMAGE_TAG)
endif

clean_docs: ## Removes the content artifacts directory (SITE_DIR) and compressed archive (SITE_DIR.zip)
	$(eval CMD := rm -rf $(SITE_DIR).zip && rm -rf $(SITE_DIR) && rm -rf $(DOCS_PROCESSED_PATH) && rm -rf $(DOCS_SITE_PATH) && rm -rf $(DOCS_ENV_PATH))
	@echo "Cleaning $(SITE_DIR).zip & $(SITE_DIR) in $(SITE_DIR)"
	$(DOCKER_COMMAND) $(BASH_CMD) '$(CMD)'

build_docs: clean_docs ## Builds the mkdocs build command to generate content to (SITE_DIR)
	$(eval CMD := preprocessor.sh && mkdocs build)
	@echo "Building"
	$(DOCKER_COMMAND) $(BASH_CMD) '$(CMD)'

debug: ## Runs the docker image interactively for debugging purposes
	$(DOCKER_COMMAND) $(CMD)

docker_build: ## Build the docker image used for these make targets
	@docker build -t $(IMAGE_TAG) .

package_docs: build_docs ## Builds the mkdocs build command to generate content to (SITE_DIR) and creates compressed archive (SITE_DIR.zip)
	$(eval CMD := cd $(DOCS_SRC_PATH) && zip -r ../$(SITE_DIR).zip ./)
	@echo "Packaging"
	$(DOCKER_COMMAND) $(BASH_CMD) '$(CMD)'

serve_docs:  ## Runs the mkdocs server at 0.0.0.0:8000
	$(eval CMD := preprocessor.sh && mkdocs serve --dev-addr=0.0.0.0:8000)
	$(DOCKER_COMMAND) $(BASH_CMD) '$(CMD)'

print-%: ; @echo $*=$($*)

printenv:
	printenv | sort
