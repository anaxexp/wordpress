-include env_make

MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := build
.PHONY: *

# we get these from CI environment if available, otherwise from git
GIT_COMMIT ?= $(shell git rev-parse --short HEAD)
GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
WORKSPACE ?= $(shell pwd)
APP_ROOT ?= /var/www/html
WP_CLI_CONFIG_PATH ?= /usr/src/wordpress/wp-cli.yml
namespace ?= anaxexp
tag := branch-$(shell basename $(GIT_BRANCH))

#dockerLocal := DOCKER_HOST= DOCKER_TLS_VERIFY= DOCKER_CERT_PATH= docker
dockerLocal := docker
#composeLocal := DOCKER_HOST= DOCKER_TLS_VERIFY= DOCKER_CERT_PATH= docker-compose
composeLocal := docker-compose

WP_VER ?= 4.9.8
WP_SHA1 ?= 0945bab959cba127531dceb2c4fed81770812b4f
WP_MD5 ?= c4e7d68b5c382fbbaf547f2b2d42c198

WP_VER_MAJOR ?= $(shell echo "${WP_VER}" | grep -oE '^[0-9]+')
HYPERDB_VERSION ?= 1.1

PHP_VER ?= 7.2
BASE_IMAGE_TAG = $(PHP_VER)

REPO := $(namespace)/wordpress
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
	$(dockerLocal) build -t=$(REPO):$(TAG) \
		--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
		--build-arg WP_VER=$(WP_VER) \
		--build-arg WP_SHA1=$(WP_SHA1) \
		--build-arg WP_MD5=$(WP_MD5) \
		--build-arg WP_CLI_CONFIG_PATH=$(WP_CLI_CONFIG_PATH) \
		--build-arg HYPERDB_VERSION=$(HYPERDB_VERSION) \
		./

test:
	cd ./tests && IMAGE=$(REPO):$(TAG) ./run.sh

## Push the current application container images to the Docker Hub
push:
	$(dockerLocal) push $(REPO):$(TAG)

## Tag the current images as 'latest'
tag:
	$(dockerLocal) tag $(REPO):$(tag) $(REPO):$(TAG) $(REPO):latest

## Push latest tag(s) to the Docker Hub
ship: tag
	$(dockerLocal) push $(REPO):$(TAG)
	$(dockerLocal) push $(REPO):latest

shell:
	$(dockerLocal) run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	$(dockerLocal) run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	$(dockerLocal) run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	$(dockerLocal) stop $(NAME)

logs:
	$(dockerLocal) logs $(NAME)

clean:
	-$(dockerLocal) rm -f $(NAME)

check-configs:
	./check-configs.sh $(WP_VER)

release: build push

# ------------------------------------------------
# Test running

## Pull the container images from the Docker Hub
pull:
	$(dockerLocal) pull $(REPO):$(TAG)

## Print environment for build debugging
debug:
	@echo WORKSPACE=$(WORKSPACE)
	@echo APP_ROOT=$(APP_ROOT)
	@echo GIT_COMMIT=$(GIT_COMMIT)
	@echo GIT_BRANCH=$(GIT_BRANCH)
	@echo namespace=$(namespace)
	@echo REPO=$(REPO)
	@echo TAG=$(TAG)
	@echo NAME=$(NAME)
	@echo PHP_VER=$(PHP_VER)
	@echo WP_VER=$(WP_VER)
	@echo WP_VER_MAJOR=$(WP_VER_MAJOR)
	@echo WP_SHA1=$(WP_SHA1)
	@echo WP_MD5=$(WP_MD5)

# -------------------------------------------------------
# helper functions for testing if variables are defined
#
check_var = $(foreach 1,$1,$(__check_var))
__check_var = $(if $(value $1),,\
	$(error Missing $1 $(if $(value 2),$(strip $2))))