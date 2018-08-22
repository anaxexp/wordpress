-include env_make

MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := build
.PHONY: *

# we get these from CI environment if available, otherwise from git
GIT_COMMIT ?= $(shell git rev-parse --short HEAD)
GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
WORKSPACE ?= $(shell pwd)

namespace ?= anaxexp
tag := branch-$(shell basename $(GIT_BRANCH))
imageWordpress := $(namespace)/wordpress
imageNginx := $(namespace)/nginx

#dockerLocal := DOCKER_HOST= DOCKER_TLS_VERIFY= DOCKER_CERT_PATH= docker
dockerLocal := docker
#composeLocal := DOCKER_HOST= DOCKER_TLS_VERIFY= DOCKER_CERT_PATH= docker-compose
composeLocal := docker-compose

WP_VER ?= 4.9.8
WP_SHA1 ?= 0945bab959cba127531dceb2c4fed81770812b4f
WP_MD5 ?= c4e7d68b5c382fbbaf547f2b2d42c198

WP_VER_MAJOR ?= $(shell echo "${WP_VER}" | grep -oE '^[0-9]+')

PHP_VER ?= 7.2
BASE_IMAGE_TAG = $(PHP_VER)

REPO = anaxexp/wordpress
NAME = wordpress-$(WP_VER_MAJOR)-$(PHP_VER)

TAG ?= $(WP_VER_MAJOR)-$(PHP_VER)

ifneq ($(BASE_IMAGE_STABILITY_TAG),)
    BASE_IMAGE_TAG := $(BASE_IMAGE_TAG)-$(BASE_IMAGE_STABILITY_TAG)
endif

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
        override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif

## Display this help message
help:
	@awk '/^##.*$$/,/[a-zA-Z_-]+:/' $(MAKEFILE_LIST) | awk '!(NR%2){print $$0p}{p=$$0}' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' | sort


build:
	$(dockerLocal) build -t=$(imageWordpress):$(tag) \
		--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
		--build-arg WP_VER=$(WP_VER) \
		--build-arg WP_SHA1=$(WP_SHA1) \
		--build-arg WP_MD5=$(WP_MD5) \
		./

test:
	cd ./tests && IMAGE=$(REPO):$(TAG) ./run.sh

## Push the current application container images to the Docker Hub
push:
	$(dockerLocal) push $(imageWordpress):$(tag)
	$(dockerLocal) push $(imageNginx):$(tag)

## Tag the current images as 'latest'
tag:
	$(dockerLocal) tag $(imageWordpress):$(tag) $(imageWordpress):latest
	$(dockerLocal) tag $(imageNginx):$(tag) $(imageNginx):latest

## Push latest tag(s) to the Docker Hub
ship: tag
	$(dockerLocal) push $(imageWordpress):$(tag)
	$(dockerLocal) push $(imageWordpress):latest
	$(dockerLocal) push $(imageNginx):$(tag)
	$(dockerLocal) push $(imageNginx):latest

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

check-configs:
	./check-configs.sh $(WP_VER)

release: build push

# ------------------------------------------------
# Test running

## Pull the container images from the Docker Hub
pull:
	$(dockerLocal) pull $(imageWordpress):$(tag)
	$(dockerLocal) pull $(imageNginx):$(tag)

## Print environment for build debugging
debug:
	@echo WORKSPACE=$(WORKSPACE)
	@echo GIT_COMMIT=$(GIT_COMMIT)
	@echo GIT_BRANCH=$(GIT_BRANCH)
	@echo namespace=$(namespace)
	@echo tag=$(tag)
	@echo imageWordpress=$(imageWordpress)
	@echo imageNginx=$(imageNginx)

# -------------------------------------------------------
# helper functions for testing if variables are defined
#
check_var = $(foreach 1,$1,$(__check_var))
__check_var = $(if $(value $1),,\
	$(error Missing $1 $(if $(value 2),$(strip $2))))