export TERRAFORM_VERSION ?= $(shell curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version' | cut -d. -f1)

.DEFAULT_GOAL : all
.PHONY: all

## Default target
all: test

.PHONY : init
## Initialize tests
init:
	@exit 0

.PHONY : test
## Run tests
test: init
	go mod download
	go test -v -timeout 60m

.PHONY : clean
## Clean up files
clean:
	rm -rf ../../examples/complete/*.tfstate*
