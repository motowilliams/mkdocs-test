SHELL := /bin/bash
BASH_CMD := ${SHELL} -c

IMAGE_NAME ?= mkdocs
IMAGE_VERSION ?= latest
IMAGE_TAG = $(IMAGE_NAME):$(IMAGE_VERSION)

WORKING_DIR = app
PROJECT_NAME ?= docs-site
SITE_NAME ?= site

ifdef CI_JOB_STAGE
DOCKER_COMMAND :=
else
DOCKER_COMMAND := docker run -it \
-v $(PWD):/${WORKING_DIR}/ \
--env SITE_NAME=${SITE_NAME} \
--rm \
-p 8000:8000 \
$(IMAGE_TAG)
endif

docker_build:
	@docker build -t $(IMAGE_TAG) .

debug:
	@pushd $(PWD) > /dev/null && \
	${DOCKER_COMMAND} && \
	popd > /dev/null

clean_docs:
	$(eval CMD := cd ${WORKING_DIR}/${PROJECT_NAME} && rm -rf ${SITE_NAME}.zip && rm -rf ${SITE_NAME})
	@echo "Cleaning ${SITE_NAME}.zip & ${SITE_NAME} in ${PROJECT_NAME}" && \
	${DOCKER_COMMAND} ${BASH_CMD} '$(CMD)'

build_docs: clean_docs
	$(eval CMD := cd ${WORKING_DIR}/${PROJECT_NAME} && mkdocs build)
	@echo "Building" && \
	pushd $(PWD) > /dev/null && \
	${DOCKER_COMMAND} ${BASH_CMD} '$(CMD)' && \
	popd > /dev/null

serve_docs:
	$(eval CMD := cd ${WORKING_DIR}/${PROJECT_NAME} && mkdocs serve --dev-addr=0.0.0.0:8000)
	@pushd $(PWD) > /dev/null && \
	${DOCKER_COMMAND} ${BASH_CMD} '$(CMD)' && \
	popd > /dev/null

package_docs: build_docs
	$(eval CMD := cd ${WORKING_DIR}/${PROJECT_NAME}/${SITE_NAME} && zip -r ../${SITE_NAME}.zip ./)
	@echo "Packaging" && \
	pushd $(PWD) > /dev/null && \
	${DOCKER_COMMAND} ${BASH_CMD} '$(CMD)' && \
	popd > /dev/null
