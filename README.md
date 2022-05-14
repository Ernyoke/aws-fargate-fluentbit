# aws-fargate-fluentbit

This repository contains the code for the article:

## Running the Code

1. Provision the ECR registry by running the following commands:

```
cd ecr-infra
terraform apply --auto-approve
```

The output of this Terraform plan/apply should be the URL of the registry, which will be used in the [task.tftpl](ecs-infra/task.tftpl) template file.

2. Build and push the Docker image following the instruction from [README](docker/README.md)

3. Fill in the [task.tftpl](ecs-infra/task.tftpl) template file the path to the Docker image:

```
"image": "<id>.dkr.ecr.us-east-1.amazonaws.com/fluent-bit-s3:latest"
```