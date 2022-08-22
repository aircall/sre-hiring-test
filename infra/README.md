# Infra strategy

Resources deployed by Terraform

- IAM role for terraform with permissions to read ECR and S3
- Lambda funcion running an ECR image
- ECR repository with the image
- S3 bucket to hold the images
- Cloudfront distribution to allow basic auth


The idea was to use a lambda@edge for auth, but I ran out of time.

I did not use an API gateway since it is not needed anymore to expose lambda to HTTP. I used the new lambda_url resource. 

## Things that I would not do on a real env

- Expose the public bucket. Ideally, I would generate pre signed url for the files.
- Use a remote backend for terraform, S3 or, ideally, terraform cloud.



## CI/CD 

- The CI/CD is pretty straighforward. It builds the image, pushes to ECR, and update the lambda with the new tag.


### Url to call the service:

- cf_domain = "d3co1nmffypdnf.cloudfront.net"
- function_url = "https://2d42jb7q5ind2to4qknpvpbd240oerts.lambda-url.eu-central-1.on.aws/"


### The bucket url with the contents:
- https://aircall-default.s3.eu-central-1.amazonaws.com



- How to deploy an env from scratch.

```
terraform init
terraform workspace new dev
terraform plan
terraform apply
```

The urls will be in the output


