---
title: "Data preparation pipeline hosted on AWS"
publishedAt: "2023-06-08"
summary: "A data preparation pipeline hosted on AWS using Kedro framework."
tags: "AWS, Data engineering"
---

This is my project completed during my software engineering internship hosted by Shine Solutions Group in Canberra in 2023. This project allows creating a modular, reproducible and maintainable data pipeline using Python's Kedro framework powered by the AWS's computing and storage resources. Data transformations are processed by AWS Lambda functions orchestrated by an AWS Step Functions state machine. The pipeline is triggered by an AWS Lambda function that is invoked by an AWS S3 bucket when a new file is uploaded to the bucket. The pipeline is deployed using Terraform via a CI/CD pipeline that validates the infrastructure's configurations. The pipeline is built using AWS CodePipeline and AWS CodeBuild. The processed data is uploaded to an AWS RDS PostgreSQL database by an AWS Lambda function.

# Project Poster

![Project Poster](https://my-portfolio-public-files.s3.ap-southeast-2.amazonaws.com/shine_internship_poster.pdf)

# Architecture Diagram

![Architecture Diagram](https://my-portfolio-public-files.s3.ap-southeast-2.amazonaws.com/shine-internship-architecture_diagram.drawio.svg)

# How to use


1. Prepare a compatible Kedro DataCatalog with the AWS S3 bucket data sources and data sets required for the pipeline.


2. Create a Kedro pipeline


3. Change the working directory to the data-processing-pipeline directory.

    ```bash
    cd data-processing-pipeline
    ```
4. Package the pipeline using the default command

    ```bash
    kedro package
    ```
5. Package the Kedro pipeline as an AWS Lambda-compliant Docker image and push it to Amazon ECR

    ```bash
    # build and tag the image
    docker build -t <your-image-name> .
    docker tag <your-image-name>:latest <your-aws-account-id>.dkr.ecr.<your-aws-region>.amazonaws.com/<your-image-name>:latest
    # login to ECR
    aws ecr get-login-password | docker login --username AWS --password-stdin <your-aws-account-id>.dkr.ecr.<your-aws-region>.amazonaws.com
    # push the image to ECR
    docker push <your-aws-account-id>.dkr.ecr.<your-aws-region>.amazonaws.com/<your-image-name>:latest
    ```

6. Run the Python script that creates the JSON file that is used to define the Step Functions state machine and the JSON file containing the list of Kedro pipeline node names used to create Lambda functions for the pipeline.

    ```bash
    python parse_pipeline.py
    ```
7. Apply the changes to the Terraform configuration by committing the changes to the CodeCommit repository.
    - This triggers the AWS CodePipeline pipeline to deploy the Kedro pipeline to AWS.


8. Upload the raw data to the s3_raw_data S3 bucket.
    - This triggers the Step Functions state machine to orchestrate the data processing pipeline. Then load_rds_lambda is invoked by the s3_processed_data S3 bucket. When a data is uploaded to this bucket, the Lambda function is triggered. The Lambda function reads the data from the source S3 bucket, processes it to create SQL queries, and writes the result to the AWS RDS PostgreSQL database.

# AWS CodePipeline CI/CD pipeline for Terraform

Terraform is an infrastructure-as-code (IaC) tool that helps you create, update, and version your infrastructure in a secure and repeatable manner.

This pattern setups a validation pipeline with infrastructure configuration and security tests based on AWS CodePipeline, AWS CodeBuild, AWS CodeCommit and Terraform.

The created pipeline has the below stages

- validate - This stage focuses on terraform IaC validation tools and commands such as terraform validate, terraform format, tfsec and checkov
- plan - This stage creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.
- apply - This stage uses the plan created above to provision the infrastructure in the test account.

Running these three stages ensures the integrity of terraform configurations.

## Modules

Terraform modules are self-contained packages of Terraform configurations that are managed as a group.

This pattern uses the following Terraform modules

- [codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) - This module creates a CodePipeline with CodeCommit as source, CodeBuild as build provider and CodeDeploy as deploy provider.
- [codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) - This module creates a CodeBuild project with terraform, tfsec and checkov as buildspec.
- [codecommit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_repository) - This module creates a CodeCommit repository with a branch and a file.
- [codepipeline-iam-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) - This module creates an IAM role for CodePipeline with policies to access other AWS services.
- [s3_codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) - This module creates an S3 bucket to store the CodePipeline artifacts.

## CodeBuild specifications

- buildspec - This directory contains the buildspec files for the CodeBuild project.
    - ./scripts
        - ./tf_ssp_validation.sh - This Bash script is designed to perform a series of validations on Terraform code.
    - ./buildspec_apply.yml - This buildspec is used to apply the terraform plan.
    - ./buildspec_plan.yml - This buildspec is used to create a terraform plan.
    - ./buildspec_validate.yml - This buildspec is used to validate the terraform code using the Bash script.

## Resources

- [AWS CodePipeline Prescriptive Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/create-a-ci-cd-pipeline-to-validate-terraform-configurations-by-using-aws-codepipeline.html)


# Building data pipelines with Kedro framework

Kedro is a Python framework that applies software engineering best-practices to data and machine learning pipelines. Kedro is used to build the data pipeline.

./data-processing-pipeline - This directory contains the Kedro project.

For more details on how to use Kedro, see ./data-processing-pipeline/README.md


# Data pipeline with AWS Lambda orchestrated by AWS Step Functions

This pipeline creates a data pipeline with AWS Lambda orchestrated by AWS Step Functions. The pipeline is triggered by an Amazon S3 event. The Lambda function is invoked by the Step Functions state machine. The Lambda function reads the data from the source Amazon S3 bucket, processes it, and writes the result to respective destinations in Amazon S3 buckets.

## Terraform modules

This pattern uses the below Terraform modules

- [lambda-iam-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) - This module creates an IAM role for Lambda with policies to access other AWS services.
- [lambda_trigger_step_functions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) - This module creates a Lambda function to trigger the Step Functions state machine when a raw data file is uploaded to the s3_raw_data_bucket
- [lambda_dpp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) - This module creates a Lambda function from each Kedro pipeline node to process the data.
    - ./lambda-content/trigger-step-function/lambda_function.py - This Python script is used to trigger the Step Functions state machine when a raw data file is uploaded to the s3_raw_data_bucket.
    - data-processing-pipeline/node_list.json - This JSON file contains the list of Kedro pipeline node names. The Lambda function is created for each node in the list.
- [s3_raw_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) - This module creates an S3 bucket to store the raw data.
- [s3_intermediate_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) - This module creates an S3 bucket to store the intermediate data created during intermediate stages of the data processing pipeline.
- [s3_processed_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) - This module creates an S3 bucket to store the processed data.
- [sfn-iam-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) - This module creates an IAM role for Step Functions with policies to access other AWS services.
- [sfn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) - This module creates a Step Functions state machine to orchestrate the data processing pipeline.
    - ./data-processing-pipeline/sfn_definition.json - This JSON file is used to define the Step Functions state machine.
    - ./modules./lambda_dpp - This module creates Lambda functions from each Kedro pipeline node to process the data.


## Resources

- [How to deploy your Kedro pipeline with AWS Step Functions](https://docs.kedro.org/en/0.18.7/deployment/aws_step_functions.html)
- [Creating a Step Functions state machine that uses Lambda](https://docs.aws.amazon.com/step-functions/latest/dg/tutorial-creating-lambda-state-machine.html)
- [Data Processing and ETL orchestration](https://aws.amazon.com/step-functions/use-cases/#Data_Processing_and_ETL_Orchestration/?pg=ln&sec=uc)
- [Using AWS Step Functions State Machines to Handle Workflow-Driven AWS CodePipeline Actions](https://aws.amazon.com/blogs/devops/using-aws-step-functions-state-machines-to-handle-workflow-driven-aws-codepipeline-actions/)
- [Creating Lambda container images](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html#images-reqs)


# Uploading processed data to AWS RDS PostgreSQL database

This pattern uploads the processed data to an AWS RDS PostgreSQL database. The data is uploaded to the database using the AWS Lambda function. The Lambda function is invoked by the s3_processed_data S3 bucket. When a data is uploaded to this bucket, the Lambda function is triggered. The Lambda function reads the data from the source S3 bucket, processes it to create SQL queries, and writes the result to the AWS RDS PostgreSQL database.

## Modules


This pattern uses the below Terraform modules

- [rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) - This module creates an AWS RDS PostgreSQL database.
- [secrets-manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) - This module creates an AWS Secrets Manager secret to store the database credentials.
    - A private connection is established between the VPC containing the database and Secrets Manager by creating an interface VPC endpoint.
- [lambda-load-rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) - This module creates a Lambda function to upload the processed data to the AWS RDS PostgreSQL database.
    - lambda-content/load-rds-function/lambda_function.py - This Python script is used to upload the processed data to the AWS RDS PostgreSQL database.


# Potential Improvements

- Use great-expectations on AWS to validate the data.

    - This can be done by creating a Lambda function to run the great-expectations tests within the Step Functions state machine.
    - great-expectations is set up in the data-processing-pipeline directory. The tests are defined in the great_expectations.yml file.
    - The tests can run on-premises.
    - A node containing the great-expectations tests is added to the Kedro pipeline. The node can be used as a checkpoint to run the tests and validate the data.
    - TODO
        - Add great-expectations package to the Docker image.

- Automate docker image build and push to ECR with Terraform