# Makefile tutorial-deploy-aws-image

# these-targets-are-not-files
.PHONY: all help deploy.test deploy deploy.tasks check.docker_registry docker.login docker.build_ docker.tag docker.build docker.push

# vars
REPO := git@github.com:arthuralvim/deploy-aws-image.git
VERSION := master
ENVIRON := staging
IMAGE_APP_VERSION := 120409133518.dkr.ecr.us-east-1.amazonaws.com/intelivix/tutorial-deploy-aws-image:887c83e

all: help

help:
	@echo 'Makefile *** tutorial-deploy-aws-image *** Makefile'

deploy.tasks:
	@ansible-playbook -i inventory deploy.yml -l deploy --extra-vars "environ=${ENVIRON} image_app_version=${IMAGE_APP_VERSION}" --list-tasks

deploy.test:
	@ansible-playbook -i inventory deploy.yml -l deploy --extra-vars "environ=${ENVIRON} image_app_version=${IMAGE_APP_VERSION}" --list-hosts

deploy:
	@ansible-playbook -i inventory deploy.yml -l deploy --extra-vars "environ=${ENVIRON} image_app_version=${IMAGE_APP_VERSION}"

deploy.undo:
	@ansible-playbook -i inventory stop.yml -l deploy --extra-vars "environ=${ENVIRON} image_app_version=${IMAGE_APP_VERSION}"

### DOCKER

# export DOCKER_REGISTRY=120409133518.dkr.ecr.us-east-1.amazonaws.com

DOCKER_NAME := intelivix/tutorial-deploy-aws-image
DOCKER_TAG := $$(if [ "${TRAVIS_TAG}" = "" ]; then echo `git log -1 --pretty=%h`; else echo "${TRAVIS_TAG}"; fi)
DOCKER_IMG_TAG := ${DOCKER_NAME}:${DOCKER_TAG}
DOCKER_LATEST := ${DOCKER_NAME}:latest
DOCKER_PR_BRANCH := ${DOCKER_NAME}:${TRAVIS_PULL_REQUEST_BRANCH}

check.docker_registry:
	@if test "$(DOCKER_REGISTRY)" = "" ; then echo "DOCKER_REGISTRY is undefined."; exit 1; fi

check.docker_image:
	@if test "$(DOCKER_PULL_IMAGE_VERSION)" = "" ; then echo "DOCKER_REGISTRY is undefined."; exit 1; fi

docker.login:
	$$(aws ecr get-login --no-include-email --region us-east-1)

docker.build_: check.docker_registry
	@echo "Build started on `date`"
	@docker build -f Dockerfile -t ${DOCKER_IMG_TAG} .
	@echo "Build completed on `date`"

docker.tag: check.docker_registry
	@if [ ! -z "${TRAVIS_PULL_REQUEST_BRANCH}" ]; then docker tag ${DOCKER_IMG_TAG} ${DOCKER_REGISTRY}/${DOCKER_PR_BRANCH}; fi
	@docker tag ${DOCKER_IMG_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMG_TAG}

docker.build: docker.build_ docker.tag

docker.actual_image: check.docker_registry
	@echo ${DOCKER_REGISTRY}/${DOCKER_IMG_TAG}

docker.push: check.docker_registry
	@echo "Pushing images started on `date`"
	@if [ ! -z "${TRAVIS_PULL_REQUEST_BRANCH}" ]; then docker push ${DOCKER_REGISTRY}/${DOCKER_PR_BRANCH}; fi
	@docker push ${DOCKER_REGISTRY}/${DOCKER_IMG_TAG}
	@echo "Pushing images completed on `date`"

docker.pull: check.docker_registry
	@echo "Pulling images started on `date`"
	@if [ ! -z "${TRAVIS_PULL_REQUEST_BRANCH}" ]; then docker pull ${DOCKER_REGISTRY}/${DOCKER_PR_BRANCH}; fi
	@docker pull ${DOCKER_REGISTRY}/${DOCKER_IMG_TAG}
	@echo "Pulling images completed on `date`"
