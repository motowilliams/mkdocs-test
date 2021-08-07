SHELL := /bin/bash

IMAGE_NAME=mkdocs
IMAGE_VERSION=latest
IMAGE_TAG=$(IMAGE_NAME):$(IMAGE_VERSION)

PROJECT_NAME=my-project
SITE_NAME?=site

docker_build:
	@docker build -t $(IMAGE_TAG) .

debug:
	@pushd $(PWD) > /dev/null && \
	docker run -it -v $(PWD):/app/ --env SITE_NAME=${SITE_NAME} --rm -w /app/${PROJECT_NAME} $(IMAGE_TAG) && \
	popd > /dev/null

build:
	@pushd $(PWD) > /dev/null && \
	docker run -it -v $(PWD):/app/ --env SITE_NAME=${SITE_NAME} --rm -w /app/${PROJECT_NAME} $(IMAGE_TAG) mkdocs build && \
	popd > /dev/null

serve:
	@pushd $(PWD) > /dev/null && \
	docker run -it -v $(PWD):/app/ --env SITE_NAME=${SITE_NAME} --rm -w /app/${PROJECT_NAME} -p 8000:8000 $(IMAGE_TAG) mkdocs serve --dev-addr=0.0.0.0:8000 && \
	popd > /dev/null

package: build
	@pushd $(PWD) > /dev/null && \
	docker run -it -v $(PWD):/app/ --env SITE_NAME=${SITE_NAME} --rm -w /app/${PROJECT_NAME}/${SITE_NAME} $(IMAGE_TAG) zip -r ../${SITE_NAME}.zip ./ && \
	popd > /dev/null
