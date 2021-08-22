#!/usr/bin/make

################################################################################
# Makefile for applying the Infrastructure
#
#
# The parameters passed to Make should be:
#
#     stack = STACK
#     environment = ENVIRONMENT
#
################################################################################

GNU_ECHO ?= /bin/echo

# Control whether to supress the echo of a command; supressed by default
Q ?= @

# The account ID of the account that hosts the terraform backend, tfstate & lock table
STATE_ACCOUNT_ID ?= 570221997972

# Region where the resource is created

region := eu-west-2

# S3 bucket where the Terraform state data is stored

bucket := image-resize-terraform-state

# S3 key where the Terraform state data is stored

tfstate_key := ${region}/${stack}.tfstate

# Where does the code live?
stack_path = "stacks/${stack}"

# Parameters passed to Terraform

ifeq ($(stack), backend)
	tf_args ?= -var-file="../../configs/${environment}/common.tfvars" -var-file="../../configs/${environment}/${stack}.tfvars" -var "environment=${environment}" -var "stack=${stack}"
else
	tf_args ?= -var-file="../../configs/${environment}/common.tfvars" -var-file="../../configs/${environment}/${stack}.tfvars" -var "environment=${environment}" -var "stack=${stack}"
endif

ifdef TF_LOCK_TIMEOUT
  tf_lock := -lock-timeout=${TF_LOCK_TIMEOUT}
else
  tf_lock :=
endif

ifdef TF_RESOURCE
  tf_target := -target=${TF_RESOURCE}
else
  tf_target :=
endif

# Logic needed to strip out tf_args if applying a saved plan

ifeq ($(TF_OUT), true)
  tf_plan := ${tf_args} -out=${environment}_${stack}_tfout
  tf_apply := ${environment}_${stack}_tfout
else
  tf_plan := ${tf_args}
  tf_apply := ${tf_args}
endif

# Role ARN

role_arn := arn:aws:iam::${STATE_ACCOUNT_ID}:role/CIAccessRole

################################################################################
# Default target

.PHONY: all
all: validate plan apply

################################################################################
# Remove the generated backend.tf file

.PHONY: clean
clean:
	${Q}rm -f ${stack_path}/backend.tf
	${Q}rm -f ${stack_path}/common_*.tf
	${Q}rm -rf ${stack_path}/.terraform

################################################################################
# Check that the values supplied on the command line are present and, where
# possible, correct.

.PHONY: check
check: clean
	${Q}echo -n "Checking for region setting ... "
	${Q}test -n "${region}" || (echo "no region setting" && exit 1)
	${Q}echo "OK"
	${Q}echo -n "Checking for bucket setting ... "
	${Q}test -n "${bucket}" || (echo "no bucket setting" && exit 1)
	${Q}echo "OK"
	${Q}echo -n "Checking for stack setting ... "
	${Q}test -n "${stack}" || (echo "no stack setting" && exit 1)
	${Q}test -d ${stack_path} || (echo "The stack does not exist" && exit 1)
	${Q}echo "OK"
	${Q}echo -n "Checking for environment setting ..."
	${Q}test -n "${environment}" || (echo "no environment setting" && exit 1)
	${Q}test -d "configs/${environment}" || (echo "No environment config exists for that environment" && exit 1)
	${Q}echo "OK"
	${Q}echo ""

################################################################################
# Create the backend configuration file (note that is declared phony to force
# the file to be recreated every time as it contains data from the Make command
# line).
# This is awaiting roles and dynamodb

.PHONY: backend.tf

define BACKEND_TF
terraform {
	backend "s3" {
		region = "${region}"
		bucket = "${bucket}"
		key = "${tfstate_key}"
		encrypt = "true"
		role_arn = "${role_arn}"
		dynamodb_table = "terraform_statelock"
	}
}
endef
export BACKEND_TF

backend.tf: check clean
	${Q}${GNU_ECHO} "$$BACKEND_TF" > ${stack_path}/backend.tf || (echo "Failed to write backend config to backend.tf" && exit 1)
	${Q}echo "Set up S3 remote state from s3 bucket ${bucket}, key env:/${environment}/${tfstate_key}"

################################################################################
# Copy common files into the stacks dir
.PHONY: common
common:
	cp common/locals.tf ${stack_path}/common_locals.tf
	cp common/variables.tf ${stack_path}/common_variables.tf

################################################################################
# Initialisation - initialise Terraform

.PHONY: init
init: check backend.tf common
	${Q}cd ${stack_path} && \
	tfenv install && \
	terraform init -reconfigure || (echo "Terraform init failed" && exit 1) && \
	terraform workspace select ${environment} || terraform workspace new ${environment} && \
	terraform init -reconfigure || (echo "Terraform init failed" && exit 1) && \
	terraform get -update=true || (echo "Terraform get failed" && exit 1)
	${Q}echo "Formatting"
	${Q}cd ${stack_path} && terraform fmt

################################################################################
# Validate the Terraform code

.PHONY: validate
validate: init
	${Q}echo "Running a validate"
	${Q}cd ${stack_path} && terraform validate
	${Q}echo "Validation passed"

################################################################################
# Run Terraform plan

.PHONY: plan
plan: init
	${Q}echo "${BLUE_API_VERSION}"
	${Q}echo "Running a plan on ${stack_path}"
	${Q}echo "Command to execute: terraform plan ${tf_lock} ${tf_target} ${tf_plan}"

	${Q}cd ${stack_path} && terraform plan ${tf_lock} ${tf_target} ${tf_plan}

################################################################################
# Run Terraform refresh

.PHONY: refresh
refresh: init
	${Q}echo "Running a refresh"
	${Q}cd ${stack_path} &&  terraform refresh ${tf_args} ${tf_lock}

################################################################################
# Run Terraform apply

.PHONY: apply
apply: init
ifeq ($(environment), prod)
	${Q}test "${PRODUCTION_DEPLOYMENT}" = "true" || (echo "Production deployment not authorised"; exit 1)
endif

	${Q}echo "Applying..."
	${Q}echo "Command to execute: terraform apply ${autoapprove} ${tf_lock} ${tf_target} ${tf_apply}"

	${Q}cd ${stack_path} && terraform apply ${autoapprove} ${tf_lock} ${tf_target} ${tf_apply}

################################################################################
# Run Terraform destroy

.PHONY: destroy
destroy: init
# 	${Q}test "${AUTOMATED_DELETE}" = "true" || (echo "Delete operation not authorised"; exit 1)
	${Q}test "${environment}" != "prod" || (echo "Production environment cannot be destroyed"; exit 1)

	${Q}echo "Destroying..."
	${Q}cd ${stack_path} && terraform destroy ${autoapprove} ${tf_args} ${tf_lock}
