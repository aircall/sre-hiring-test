SHELL := /bin/bash

ifndef REGION
$(error REGION is not set)
endif
ifndef ENVNAME
$(error ENVNAME is not set)
endif

# vars to import
VARS=--var "envname=$(ENVNAME)"\
-var "aws_region=$(REGION)"

ifneq (,$(wildcard tfvars/$(ENVNAME)_$(REGION).tfvars))
    VARFILE+= -var-file=tfvars/$(ENVNAME)_$(REGION).tfvars
endif

SF_REGION="us-east-1"
export AWS_DEFAULT_REGION=$(REGION)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: init plan apply test 

init:
	@printf "\nRUNNING terraform init\n\n"
	bash -c "rm -rf .terraform ./modules tfplan && terraform init -backend=true -get=true -backend-config=bucket=terraform-state-aircall-$(ENVNAME) -backend-config=key=sre-aircall/${REGION}/terraform.tfstate -backend-config=region=$(SF_REGION)"

plan: init
	@printf "\nRUNNING terraform plan\n\n"	
	bash -c "terraform plan $(VARS) $(VARFILE) -out tfplan ."

apply:
	@printf "\nRUNNING terraform apply\n\n"
	bash -c "terraform apply -auto-approve tfplan"

destroy:
	@printf "\nRUNNING terraform destroy\n\n"
	bash -c "terraform destroy -auto-approve $(VARS) $(VARFILE) "

test: 
	$(MAKE) plan 
	$(MAKE) test_terraform_compliance

test_terraform_compliance:
	@printf "\nRUNNING terraform-compliance t\n\n"
	terraform-compliance -p tfplan --feature ./features/
	rm tfplan
	rm tfplan.json

.DEFAULT_GOAL := all
.PHONY: all init plan apply test destroy