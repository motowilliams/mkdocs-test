.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

SHELL := /bin/bash
BASH_CMD := ${SHELL} -c

IMAGE_NAME ?= mkdocs
IMAGE_VERSION ?= latest
IMAGE_TAG = $(IMAGE_NAME):$(IMAGE_VERSION)

PROJECT_NAME ?= docs-site
DOCS_SRC ?= docs
DOCS_DIR ?= processed
SITE_NAME ?= site
SITE_URL ?= https://example.com/

ifdef CI_JOB_STAGE
export WORKING_DIR := ${PWD}/
export PROJECT_PATH=${WORKING_DIR}${PROJECT_NAME}
export DOCS_SRC_PATH=${WORKING_DIR}${PROJECT_NAME}/${DOCS_SRC}
export DOCS_PROCESSED_PATH=${WORKING_DIR}${PROJECT_NAME}/${DOCS_DIR}
DOCKER_COMMAND :=
else
WORKING_DIR := /app/
PROJECT_PATH=${WORKING_DIR}${PROJECT_NAME}
DOCS_SRC_PATH=${WORKING_DIR}${PROJECT_NAME}/${DOCS_SRC}
DOCS_PROCESSED_PATH=${WORKING_DIR}${PROJECT_NAME}/${DOCS_DIR}
DOCKER_COMMAND := docker run -it \
-v $(PWD):/${WORKING_DIR}/ \
--env DOCS_DIR=${DOCS_DIR} \
--env SITE_NAME=${SITE_NAME} \
--env SITE_URL=${SITE_URL} \
--env DOCS_SRC_PATH=${DOCS_SRC_PATH} \
--env DOCS_PROCESSED_PATH=${DOCS_PROCESSED_PATH} \
--env PROJECT_PATH=${PROJECT_PATH} \
--env WORKING_DIR=${WORKING_DIR} \
--rm \
-p 8000:8000 \
$(IMAGE_TAG)
endif

# markdown-pp $i -o ../processed/$i
clean_docs: ## Removes the content artifacts directory (SITE_NAME) and compressed archive (SITE_NAME.zip)
	$(eval CMD := cd ${PROJECT_PATH} && rm -rf ${SITE_NAME}.zip && rm -rf ${SITE_NAME})
	@echo "Cleaning ${SITE_NAME}.zip & ${SITE_NAME} in ${PROJECT_NAME}" && \
	${DOCKER_COMMAND} ${BASH_CMD} '$(CMD)'

build_docs: clean_docs ## Builds the mkdocs build command to generate content to (SITE_NAME)
	$(eval CMD := cd ${PROJECT_PATH} && preprocessor.sh && mkdocs build)
	@echo "Building"
	${DOCKER_COMMAND} ${BASH_CMD} '$(CMD)'

debug: ## Runs the docker image interactively for debugging purposes
	${DOCKER_COMMAND} ${CMD}

docker_build: ## Build the docker image used for these make targets
	@docker build -t $(IMAGE_TAG) .

package_docs: build_docs ## Builds the mkdocs build command to generate content to (SITE_NAME) and creates compressed archive (SITE_NAME.zip)
	$(eval CMD := cd ${PROJECT_PATH}/${SITE_NAME} && zip -r ../${SITE_NAME}.zip ./)
	@echo "Packaging"
	${DOCKER_COMMAND} ${BASH_CMD} '$(CMD)' && \

serve_docs:  ## Runs the mkdocs server at 0.0.0.0:8000
	printenv | sort
	$(eval CMD := cd ${PROJECT_PATH} && mkdocs serve --dev-addr=0.0.0.0:8000)
	${DOCKER_COMMAND} ${BASH_CMD} '$(CMD)' && \
