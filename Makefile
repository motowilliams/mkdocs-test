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
DOCKER_COMMAND :=
WORKING_DIR :=
DOCS_SRC=${WORKING_DIR}${PROJECT_NAME}/${DOCS_SRC}
DOCS_PROCESSED=${WORKING_DIR}${PROJECT_NAME}/${DOCS_DIR}
else
WORKING_DIR := /app/
DOCKER_COMMAND := docker run -it \
-v $(PWD):/${WORKING_DIR}/ \
--env DOCS_DIR=${DOCS_DIR} \
--env SITE_NAME=${SITE_NAME} \
--env SITE_URL=${SITE_URL} \
--env DOCS_SRC=${WORKING_DIR}${PROJECT_NAME}/${DOCS_SRC} \
--env DOCS_PROCESSED=${WORKING_DIR}${PROJECT_NAME}/${DOCS_DIR} \
--rm \
-p 8000:8000 \
$(IMAGE_TAG)
endif

# markdown-pp $i -o ../processed/$i
clean_docs: ## Removes the content artifacts directory (SITE_NAME) and compressed archive (SITE_NAME.zip)
	$(eval CMD := cd ${WORKING_DIR}${PROJECT_NAME} && rm -rf ${SITE_NAME}.zip && rm -rf ${SITE_NAME})
	@echo "Cleaning ${SITE_NAME}.zip & ${SITE_NAME} in ${PROJECT_NAME}" && \
	${DOCKER_COMMAND} ${BASH_CMD} '$(CMD)'

build_docs: clean_docs ## Builds the mkdocs build command to generate content to (SITE_NAME)
	$(eval CMD := cd ${WORKING_DIR}${PROJECT_NAME} && preprocessor.sh && mkdocs build)
	@echo "Building" && \
	pushd $(PWD) > /dev/null && \
	${DOCKER_COMMAND} ${BASH_CMD} '$(CMD)' && \
	popd > /dev/null

debug: ## Runs the docker image interactively for debugging purposes
	@pushd $(PWD) > /dev/null && \
	${DOCKER_COMMAND} && \
	popd > /dev/null

docker_build: ## Build the docker image used for these make targets
	@docker build -t $(IMAGE_TAG) .

package_docs: build_docs ## Builds the mkdocs build command to generate content to (SITE_NAME) and creates compressed archive (SITE_NAME.zip)
	$(eval CMD := cd ${WORKING_DIR}${PROJECT_NAME}/${SITE_NAME} && zip -r ../${SITE_NAME}.zip ./)
	@echo "Packaging" && \
	pushd $(PWD) > /dev/null && \
	${DOCKER_COMMAND} ${BASH_CMD} '$(CMD)' && \
	popd > /dev/null

serve_docs:  ## Runs the mkdocs server at 0.0.0.0:8000
	$(eval CMD := cd ${WORKING_DIR}${PROJECT_NAME} && mkdocs serve --dev-addr=0.0.0.0:8000)
	@pushd $(PWD) > /dev/null && \
	${DOCKER_COMMAND} ${BASH_CMD} '$(CMD)' && \
	popd > /dev/null
