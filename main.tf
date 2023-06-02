terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.59.0"
    }
  }
    backend "s3" {
    bucket = "terraform-state-bucket-123456"
    key    = "terraform.tfstate"
    region = "ap-southeast-2"
  }
}

provider "aws" {
  region  = "ap-southeast-2"
}

# Fetch the default VPC
resource "aws_default_vpc" "default" {
}

# Fetch the default VPC subnets
resource "aws_default_subnet" "ap_southeast_2a" {
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "Default subnet for ap-southeast-2a"
  }
}

resource "aws_default_subnet" "ap_southeast_2b" {
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "Default subnet for ap-southeast-2a"
  }
}

resource "aws_default_subnet" "ap_southeast_2c" {
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "Default subnet for ap-southeast-2a"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_default_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.existing.id
  }
}


# Module for raw data ingestion Lambda
module "lambda_load_rds" {
  source = "./modules/lambda_load_rds"
  kms_key_arn       = module.codepipeline_kms.arn
  lambda_role_arn   = module.lambda_iam_role.arn
  project_name      = var.project_name
  subnet_ids        = [aws_default_subnet.ap_southeast_2a.id, aws_default_subnet.ap_southeast_2b.id, aws_default_subnet.ap_southeast_2c.id]
  security_group_ids = [aws_default_vpc.default.default_security_group_id]
  tags              = {}
  vpc_id = aws_default_vpc.default.id
}


# Module for a RDS data store
module "rds" {
  source = "./modules/rds"
  tags = {
  }
  rds_password       = module.secrets-manager.rds_password
}


# Module for a S3 bucket for storing intermediate data
module "s3_intermediate_data" {
  source = "./modules/s3_intermediate_data"
  lambda_iam_role_arn  = module.lambda_iam_role.arn
  codepipeline_role_arn = module.codepipeline_iam_role.arn
}


# Module for a S3 bucket for storing processed data
module "s3_processed_data" {
  source                = "./modules/s3_processed_data"
  codepipeline_role_arn = module.codepipeline_iam_role.arn
  lambda_iam_role_arn   = module.lambda_iam_role.arn
}


# Module for a S3 bucket for storing validated data
module "s3_validated_data" {
  source                = "./modules/s3_validated_data"
  project_name          = var.project_name
  kms_key_arn           = module.codepipeline_kms.arn
  lambda_iam_role_name  = module.lambda_iam_role.role_name
  lambda_iam_role_arn   = module.lambda_iam_role.arn
  lambda_function_arn   = module.lambda_load_rds.arn
  lambda_function_name  = module.lambda_load_rds.name
  codepipeline_role_arn = module.codepipeline_iam_role.arn
  security_group_ids = [aws_default_vpc.default.default_security_group_id]
  vpc_id             = aws_default_vpc.default.id
  vpc_subnet = aws_default_subnet.ap_southeast_2a.id
  tags = {
  }
  route_table_id = aws_route_table.main.id
}


# Module for a S3 bucket for storing pipeline artifacts
module "s3_artifacts_bucket" {
  source                = "./modules/s3_codepipeline"
  project_name          = var.project_name
  kms_key_arn           = module.codepipeline_kms.arn
  codepipeline_role_arn = module.codepipeline_iam_role.arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}


# Module for the Lambda IAM role
module "lambda_iam_role" {
  source                     = "./modules/lambda-iam-role"
  project_name               = var.project_name
  lambda_iam_role_name = var.lambda_iam_role_name
  kms_key_arn                = module.codepipeline_kms.arn
  tags = {
    Project_Name = var.project_name
  }
  secret_arn = module.secrets-manager.secret_arn

  processed_s3_arn = module.s3_processed_data.arn
  intermediate_s3_arn = module.s3_intermediate_data.arn
  raw_s3_arn          = module.s3_raw_data.arn
  validated_s3_arn    = module.s3_validated_data.arn
}


# Module for Infrastructure Source code repository
module "source_repo" {
  source = "./modules/codecommit"
  source_repository_name   = var.source_repo_name
  source_repository_branch = var.source_repo_branch
  kms_key_arn              = module.codepipeline_kms.arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}


# Module for Infrastructure Validation - CodeBuild
module "codebuild_terraform" {
  source = "./modules/codebuild"
  depends_on = [
    module.source_repo
  ]

  project_name                        = var.project_name
  role_arn                            = module.codepipeline_iam_role.arn
  s3_bucket_name                      = module.s3_artifacts_bucket.bucket
  build_projects                      = var.build_projects
  build_project_source                = var.build_project_source
  builder_compute_type                = var.builder_compute_type
  builder_image                       = var.builder_image
  builder_image_pull_credentials_type = var.builder_image_pull_credentials_type
  builder_type                        = var.builder_type
  kms_key_arn                         = module.codepipeline_kms.arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}


# Module for KMS (Key Management Service), encryption and key management service
module "codepipeline_kms" {
  source                = "./modules/kms"
  codepipeline_role_arn = module.codepipeline_iam_role.arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}


# Module for the CodePipeline iam role
module "codepipeline_iam_role" {
  source                     = "./modules/codepipeline-iam-role"
  project_name               = var.project_name
  codepipeline_iam_role_name = var.codepipeline_iam_role_name
  source_repository_name     = var.source_repo_name
  kms_key_arn                = module.codepipeline_kms.arn
  s3_artifacts_bucket_arn        = module.s3_artifacts_bucket.arn
  s3_raw_bucket_arn              = module.s3_processed_data.arn
  rds_arn                     = module.rds.arn
  source_repository_arn     = module.source_repo.arn
  ecr_repo_arn = module.ecr_repo.arn
  codepipeline_arn = module.codepipeline_terraform.arn
  lambda_raw_data_ingestion_arn = module.lambda_load_rds.arn
  sfn_arn = module.sfn.arn

  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}


# Module for Infrastructure Validate, Plan, Apply and Destroy - CodePipeline
module "codepipeline_terraform" {
  depends_on = [
    module.codebuild_terraform,
    module.s3_artifacts_bucket
  ]
  source = "./modules/codepipeline"

  project_name          = var.project_name
  source_repo_name      = var.source_repo_name
  source_repo_branch    = var.source_repo_branch
  s3_bucket_name        = module.s3_artifacts_bucket.bucket
  codepipeline_role_arn = module.codepipeline_iam_role.arn
  stages                = var.stage_input
  kms_key_arn           = module.codepipeline_kms.arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}


# Module for ECR (Elastic Container Registry) repository
module "ecr_repo" {
  source = "./modules/ecr"
}


# Module for ECR push role
module "ecr_iam_role" {
  source       = "./modules/ecr-iam-role"
  ecr_repository_arn = module.ecr_repo.arn
}


# Module for lambda functions to run data pipeline nodes in the state machine
module "lambda_dpp" {
  source = "./modules/lambda_dpp"
  kms_key_arn       = module.codepipeline_kms.arn
  lambda_role_arn   = module.lambda_iam_role.arn
}


module "sfn" {
 source = "./modules/sfn"
  depends_on = [
      module.lambda_dpp.lambda_functions
  ]
  dpp-iam-role-arn = module.lambda_iam_role.arn
  lambda_functions = module.lambda_dpp.lambda_functions
  sfn_iam_role = module.sfn_iam_role.arn
}


module "sfn_iam_role" {
  source = "./modules/sfn-iam-role"
  sfn_arn = module.sfn.arn
  lambda_functions = module.lambda_dpp.lambda_functions
}

module "secrets-manager" {
  source = "./modules/secrets-manager"
  security_group_ids = [aws_default_vpc.default.default_security_group_id]
  vpc_id             = aws_default_vpc.default.id
  vpc_subnet = aws_default_subnet.ap_southeast_2a.id
}


module "lambda_trigger_step_function" {
  source = "./modules/lambda_trigger_step_functions"
  kms_key_arn = module.codepipeline_kms.arn
  lambda_role_arn = module.lambda_iam_role.arn
  project_name = var.project_name
}


module "s3_raw_data" {
    source = "./modules/s3_raw_data"
    kms_key_arn = module.codepipeline_kms.arn
    codepipeline_role_arn = module.codepipeline_iam_role.arn
    lambda_function_arn   = module.lambda_trigger_step_function.arn
    lambda_function_name  = module.lambda_trigger_step_function.name
    lambda_iam_role_arn   = module.lambda_iam_role.arn
    lambda_iam_role_name  = module.lambda_iam_role.role_name
}
