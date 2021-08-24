# Aircall.io - DevOps technical test - IaC
--------------------------------

[![CI Pipeline Runners](https://github.com/lbaiao2019/sam-node-project/actions/workflows/ci-pipeline.yml/badge.svg)](https://github.com/lbaiao2019/sam-node-project/actions/workflows/ci-pipeline.yml)

[![CD Pipeline Runners](https://github.com/lbaiao2019/sam-node-project/actions/workflows/cd-pipeline.yml/badge.svg)](https://github.com/lbaiao2019/sam-node-project/actions/workflows/cd-pipeline.yml)

Repository containing the logic to build Iac.

ℹ️ Without permissions to configure the repository to complete CI/CD workflows with the Github Actions, the repository has been cloned to https://github.com/lbaiao2019/sam-node-project


![Alt text](https://github.com/lbaiao2019/sam-node-project/blob/main/_doc/image.png)


## Getting Started 
### Software Prerequisites
--------------------------
 Before you get started you will need to have the following software on your laptop:      
      
* [Terraform](https://www.terraform.io/downloads.html) (>=v0.14.00)
* [Terraform Compliance](https://terraform-compliance.com/pages/installation/pip.html) (>=v1.3.24)
* [Make](https://www.gnu.org/software/make/)      
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) (>=2.0.8)

### AWS Access Prerequisites 
----------------------------
You will also need permission for Github Actions to deploy the IaC and deploy the application:

* AWS ACCESS KEY ID 
* AWS_SECRET_ACCESS_KEY

You have to create these secrets on the Github Repostory project.

### How it works
----------------
The repo currently contains logic to build, test, and deploy infrastructure and application.

- Structure:
```
.
├── Dockerfile
├── README.md
├── _doc
│   └── image.png
├── app.js
├── iac
│   ├── Makefile
│   ├── README.md
│   ├── api.tf
│   ├── backend.tf
│   ├── features
│   │   └── required.feature
│   ├── lambda.tf
│   ├── locals.tf
│   ├── providers.tf
│   ├── s3.tf
│   ├── tfvars
│   │   └── integration.tfvars
│   └── variables.tf
├── package-lock.json
├── package.json
├── parser.js
└── test
    ├── cat.jpg
    ├── payload.json
    └── python.jpg
```

To build the resources is simply:
```shell script
make plan ENVNAME=integration REGION=us-east-1
```

### Commands
------------
`make init`
<br />Performs initialization process including a `terraform init`

`make plan`
<br />Executes the logic needed to perform a `terraform plan`

`make apply`
<br />Executes the logic needed to perform a `terraform apply`

`make destroy`
<br />Executes the logic needed to perform a `terraform destroy`

`make test`
<br />Executes the logic needed to perform automated tests including `terraform-compliance` testing

### Tests 
--------- 
To run the tests:

```shell script
make test ENVNAME=integration REGION=us-east-1
```

Prerequisites: To tests must be a bucket with the name: `aircall-test-bucket` configured in the Dockerfile.


This command will run the automated tests for this account.

When all the tests pass you should see a final output similar to this:
<br />![Sample Test Result](https://github.com/lbaiao2019/sam-node-project/blob/main/_doc/test-result.png)

### GitHub Action 
--------- 

#### CI Pipeline

CI Pipeline will test the application, build, and test IaC.

<br />![Sample Pipeline](https://github.com/lbaiao2019/sam-node-project/blob/main/_doc/ci-pipeline.png)

We are testing the application on a docker container that will simulate the Lambda.
<br />https://hub.docker.com/r/amazon/aws-lambda-nodejs

Prerequisites: Create these variables in ci-pipeline
```
  SERVICE: resize  -- service name
  TF_VERSION: 0.14.0  -- terraform version
  NODE_VERSION: 14 -- node version
```
Workflow: https://github.com/lbaiao2019/sam-node-project/actions/workflows/ci-pipeline.yml

* The workflow will start manually or when create a Pull Request in the repository.

#### CD Pipeline

CD Pipeline will build, and deploy IaC and application.

<br />![Sample Pipeline](https://github.com/lbaiao2019/sam-node-project/blob/main/_doc/cd-pipeline.png)

Prerequisites: Create these variables in cd-pipeline
```
  SERVICE: resize  -- service name
  TF_VERSION: 0.14.0  -- terraform version
  NODE_VERSION: 14 -- node version
```

Workflow: https://github.com/lbaiao2019/sam-node-project/actions/workflows/cd-pipeline.yml

* The workflow will start manually or in the Merge.

