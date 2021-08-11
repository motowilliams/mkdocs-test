.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN (FS = ":.*?## "); (printf "\033[36m%-30s\033[0m %s\n", $$1, $$2)'

print-%: ; @echo $*=$($*)

SHELL := /bin/bash
BASH_CMD := $(SHELL) -c
GIT_HASH ?= $(shell git rev-parse --short HEAD)

IMAGE_NAME ?= mkdocs
IMAGE_VERSION ?= latest
IMAGE_TAG = $(IMAGE_NAME):$(IMAGE_VERSION)

PROJECT_DIR ?= docs-site
SITE_NAME?='Sample Site'
DOCS_SRC ?= docs
DOCS_DIR ?= processed
SITE_DIR ?= site
SITE_URL ?= https://example.com/

ifdef CI_JOB_STAGE
export WORKING_DIR := $(PWD)/
export PROJECT_PATH=$(WORKING_DIR)$(PROJECT_DIR)
export DOCS_SRC_PATH=$(WORKING_DIR)$(PROJECT_DIR)/$(DOCS_SRC)
export DOCS_PROCESSED_PATH=$(WORKING_DIR)$(PROJECT_DIR)/$(DOCS_DIR)
export COMMIT_HASH=$(GIT_HASH)
DOCKER_COMMAND :=
else
export WORKING_DIR := /app/
export PROJECT_PATH=$(WORKING_DIR)$(PROJECT_DIR)
export DOCS_SRC_PATH=$(WORKING_DIR)$(PROJECT_DIR)/$(DOCS_SRC)
export DOCS_PROCESSED_PATH=$(WORKING_DIR)$(PROJECT_DIR)/$(DOCS_DIR)
export COMMIT_HASH=$(GIT_HASH)
DOCKER_COMMAND := docker run -it \
-v $(PWD):$(WORKING_DIR) \
--env DOCS_DIR=$(DOCS_DIR) \
--env SITE_NAME=$(SITE_NAME) \
--env SITE_DIR=$(SITE_DIR) \
--env SITE_URL=$(SITE_URL) \
--env DOCS_SRC_PATH=$(DOCS_SRC_PATH) \
--env DOCS_PROCESSED_PATH=$(DOCS_PROCESSED_PATH) \
--env PROJECT_PATH=$(PROJECT_PATH) \
--env WORKING_DIR=$(WORKING_DIR) \
--env COMMIT_HASH=$(GIT_HASH) \
--rm \
-p 8000:8000 \
$(IMAGE_TAG)
endif

# markdown-pp $i -o ../processed/$i
clean_docs: ## Removes the content artifacts directory (SITE_DIR) and compressed archive (SITE_DIR.zip)
	$(eval CMD := rm -rf $(SITE_DIR).zip && rm -rf $(SITE_DIR))
	@echo "Cleaning $(SITE_DIR).zip & $(SITE_DIR) in $(PROJECT_DIR)" && \
	$(DOCKER_COMMAND) $(BASH_CMD) '$(CMD)'

build_docs: clean_docs ## Builds the mkdocs build command to generate content to (SITE_DIR)
	$(eval CMD := cd $(PROJECT_PATH) && preprocessor.sh && mkdocs build)
	@echo "Building"
	$(DOCKER_COMMAND) $(BASH_CMD) '$(CMD)'

debug: ## Runs the docker image interactively for debugging purposes
	$(DOCKER_COMMAND) $(CMD)

docker_build: ## Build the docker image used for these make targets
	@docker build -t $(IMAGE_TAG) .

package_docs: build_docs ## Builds the mkdocs build command to generate content to (SITE_DIR) and creates compressed archive (SITE_DIR.zip)
	$(eval CMD := cd $(PROJECT_PATH)/$(SITE_DIR) && zip -r ../$(SITE_DIR).zip ./)
	@echo "Packaging"
	$(DOCKER_COMMAND) $(BASH_CMD) '$(CMD)'

serve_docs:  ## Runs the mkdocs server at 0.0.0.0:8000
	$(eval CMD := cd $(PROJECT_PATH) && preprocessor.sh && mkdocs serve --dev-addr=0.0.0.0:8000)
	$(DOCKER_COMMAND) $(BASH_CMD) '$(CMD)'
