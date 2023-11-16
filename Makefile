# Compiler variables.
VERSION = $$(git rev-parse --short HEAD)

# Go build variables.
GOCMD = go
GOTEST = $(GOCMD) test -mod=vendor
GOBUILD = CGO_ENABLED=1 $(GOCMD) build -mod=vendor -installsuffix 'static' -ldflags "-X main.version=$(VERSION)"
GOLINT = golangci-lint run

# Source repository variables.
ROOT_DIR := $(shell git rev-parse --show-toplevel)
BIN_DIR = $(ROOT_DIR)/bin
TEST_PKGS = $(shell go list ./...)
TEST_RESULTS_DIRECTORY=$(BIN_DIR)/testresults
SCRIPTS_DIR=$(ROOT_DIR)/scripts

.DEFAULT_GOAL := help

.PHONY: build
build: ## Build the peerd packages
	@echo "+ $@"
	@( $(GOBUILD) ./... )

.PHONY: help
help: info ## Generates help for all targets with a description.
# Read the makefile and print out all targets that have a comment after them.
# If external Makefiles are referenced, trim the external reference from the target name. ex. Makefile:help: -> help:
# Sort the output.
# Split the string based on the Field Separator (FS) and print the first and second fields.
	@grep -E '^[^#[:space:]].*?## .*$$' $(MAKEFILE_LIST) | sed -E 's/^[^:]+:([^:]+:)/\1/' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install-linter
install-linter: ## Install Go linter.
	@echo "+ $@"
	@( curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin v1.54.2 )

info: header

define HEADER

	 _____	                _
	|  __ \                | |
	| |__) |__  ___ _ __ __| |
	|  ___/ _ \/ _ \ '__/ _` |
	| |  |  __/  __/ | | (_| |
	|_|   \___|\___|_|  \__,_|
                         
endef

export HEADER

header:
	@echo "$$HEADER"

# build-image-internal takes the dockerfile location, repository name and build context.
# Example: 
define build-image-internal
	@echo "\033[92mBuilding Image: $2\033[0m"

	@echo docker build -f $1 \
	-t localhost/$2:dev \
	$3

	@docker build -f $1 \
	-t localhost/$2:dev \
	$3
endef
